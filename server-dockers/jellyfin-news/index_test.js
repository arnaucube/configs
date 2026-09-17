// Run with node --test index_test.js; no browser dependencies are required.
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

// Exercise the page's actual handlers against a minimal DOM and fetch stub.
function page(options = {}) {
  const ids = ['period', 'week-controls', 'month-controls', 'week-offset', 'month-offset', 'added', 'watched', 'posters', 'collage', 'collage-preview', 'collage-download', 'copy', 'output', 'status'];
  const elements = Object.fromEntries(ids.map(id => [id, {
    value: id === 'period' ? 'current-week' : '-1',
    events: {}, valid: true,
    addEventListener(event, handler) { this.events[event] = handler; },
    reportValidity() { return this.valid; },
    removeAttribute(name) { delete this[name]; },
  }]));
  const requests = [];
  const revoked = [];
  const drawn = [];
  const textPositions = [];
  const canvas = {
    getContext: () => ({
      scale() {}, fillRect() {}, drawImage() { drawn.push('poster'); },
      fillText(text, x, y) { drawn.push(text); textPositions.push({ text, x, y }); },
      measureText: text => ({ width: text.length * 10 }),
    }),
    toBlob: callback => callback(options.exportFails ? null : new Blob(['png'], { type: 'image/png' })),
  };
  const script = fs.readFileSync(`${__dirname}/index.html`, 'utf8').split('<script>')[1].split('</script>')[0];
  vm.runInNewContext(script, {
    URLSearchParams,
    URL: { createObjectURL: () => 'blob:collage', revokeObjectURL: url => revoked.push(url) },
    setTimeout, clearTimeout,
    Image: class {
      naturalWidth = 480;
      naturalHeight = 720;
      set src(value) { if (value) queueMicrotask(() => value.includes('missing') ? this.onerror() : this.onload()); }
    },
    document: {
      createElement: () => canvas,
      querySelector: selector => elements[selector.slice(1)],
      querySelectorAll: selector => selector === 'input'
        ? [elements['week-offset'], elements['month-offset']] : Object.values(elements),
    },
    fetch: async url => {
      requests.push(url);
      return options.response || { ok: true, text: async () => 'recap', json: async () => options.data || { titles: [] } };
    },
  });
  return { elements, requests, revoked, drawn, textPositions, canvas };
}

test('period selection fetches nothing and watched can run first for every period', () => {
  for (const period of ['current-week', 'week', 'month']) {
    const { elements, requests } = page();
    elements.output.value = 'old recap';
    elements.period.value = period;
    elements.period.events.change();
    assert.deepEqual(requests, []);
    assert.equal(elements.output.value, '');
    assert.equal(elements['week-controls'].hidden, period !== 'week');
    assert.equal(elements['month-controls'].hidden, period !== 'month');
    elements.watched.events.click();
    const url = new URL(requests[0], 'http://localhost');
    assert.equal(url.pathname, '/api/watched');
    assert.equal(url.searchParams.get('period'), period);
    assert.equal(url.searchParams.get('offset'), period === 'current-week' ? null : '-1');
  }
});

test('both report actions use the explicit period and edited offset', () => {
  for (const period of ['current-week', 'week', 'month']) {
    for (const action of ['added', 'watched']) {
      const { elements, requests } = page();
      elements.period.value = period;
      elements.period.events.change();
      if (period !== 'current-week') {
        elements[`${period}-offset`].value = '-3';
        elements[`${period}-offset`].events.input();
      }
      assert.equal(requests.length, 0);
      elements[action].events.click();
      const url = new URL(requests[0], 'http://localhost');
      assert.equal(url.pathname, action === 'added' ? `/api/${period}` : '/api/watched');
      assert.equal(url.searchParams.get('offset'), period === 'current-week' ? null : '-3');
    }
  }
});

test('invalid offsets prevent either report, but do not affect current week', () => {
  for (const action of ['added', 'watched']) {
    const { elements, requests } = page();
    elements.period.value = 'week';
    elements['week-offset'].valid = false;
    elements[action].events.click();
    assert.equal(requests.length, 0);
    elements.period.value = 'current-week';
    elements[action].events.click();
    assert.equal(requests.length, 1);
  }
});

test('poster generation uses every selected period, including months', async () => {
  for (const period of ['current-week', 'week', 'month']) {
    const { elements, requests } = page();
    elements.period.value = period;
    if (period !== 'current-week') elements[`${period}-offset`].value = '-2';
    await elements.posters.events.click();
    const url = new URL(requests[0], 'http://localhost');
    assert.equal(url.pathname, '/api/posters');
    assert.equal(url.searchParams.get('period'), period);
    assert.equal(url.searchParams.get('offset'), period === 'current-week' ? null : '-2');
    assert.equal(elements.collage.hidden, true);
    assert.match(elements.status.textContent, /No new movies/);
    assert.equal(elements.posters.disabled, false);
  }
});

test('invalid poster offset prevents fetching', async () => {
  const { elements, requests } = page();
  elements.period.value = 'month';
  elements['month-offset'].valid = false;
  await elements.posters.events.click();
  assert.deepEqual(requests, []);
});

const collageData = {
  start: '2026-08-01', end: '2026-09-01', title: 'Monthly update',
  titles: [
    { name: 'Movie', kind: 'Movies', url: '/api/poster/movie' },
    { name: 'Show', kind: 'Shows', url: '/api/poster/missing' },
  ],
};

test('collage groups posters beneath one heading per category, including partial rows', async () => {
  for (const kinds of [['Movies', 'Shows'], ['Películas', 'Series'], ['Shows']]) {
    const titles = kinds.flatMap(kind => Array.from({ length: 3 }, (_, i) => ({
      name: `${kind} title ${i}`, kind, url: '',
    })));
    const { elements, textPositions, canvas } = page({ data: { ...collageData, titles } });
    await elements.posters.events.click();
    assert.equal(elements.collage.hidden, false);
    let previousBottom = 0;
    for (const kind of kinds) {
      const headings = textPositions.filter(item => item.text === kind);
      assert.equal(headings.length, 1);
      assert.ok(headings[0].y > previousBottom);
      const captions = textPositions.filter(item => item.text.startsWith(`${kind} title`));
      assert.equal(captions.length, 3);
      assert.ok(captions.every(item => item.y > headings[0].y));
      assert.equal(captions[0].x, headings[0].x);
      previousBottom = Math.max(...captions.map(item => item.y));
    }
    assert.ok(canvas.height > previousBottom);
    if (kinds.length === 1) assert.ok(!textPositions.some(item => item.text === 'Movies'));
  }
});

test('collage includes missing artwork and can be downloaded and cleared', async () => {
  const { elements, drawn, revoked } = page({ data: collageData });
  await elements.posters.events.click();
  assert.equal(elements.collage.hidden, false);
  assert.equal(elements['collage-download'].href, 'blob:collage');
  assert.equal(elements['collage-download'].download, 'jellyfin-posters-2026-08-01-2026-09-01.png');
  assert.equal(elements['collage-preview'].src, 'blob:collage');
  assert.ok(drawn.includes('poster'));
  assert.ok(drawn.includes('Show'));
  assert.ok(drawn.includes('Poster unavailable'));
  assert.match(elements.status.textContent, /1 poster\(s\) unavailable/);
  elements.period.events.change();
  assert.deepEqual(revoked, ['blob:collage']);
  assert.equal(elements.collage.hidden, true);
  assert.equal(elements['collage-download'].href, undefined);
});

test('poster request and export failures restore controls without a stale download', async () => {
  for (const options of [
    { response: { ok: false, text: async () => 'Could not query Jellyfin.' } },
    { data: collageData, exportFails: true },
  ]) {
    const { elements } = page(options);
    await elements.posters.events.click();
    assert.match(elements.status.textContent, /Could not/);
    assert.equal(elements.posters.disabled, false);
    assert.equal(elements.period.disabled, false);
    assert.equal(elements.collage.hidden, true);
  }
});
