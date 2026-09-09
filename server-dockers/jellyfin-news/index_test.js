// Run with node --test index_test.js; no browser dependencies are required.
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

// Exercise the page's actual handlers against a minimal DOM and fetch stub.
function page() {
  const ids = ['period', 'week-controls', 'month-controls', 'week-offset', 'month-offset', 'added', 'watched', 'copy', 'output', 'status'];
  const elements = Object.fromEntries(ids.map(id => [id, {
    value: id === 'period' ? 'current-week' : '-1',
    events: {}, valid: true,
    addEventListener(event, handler) { this.events[event] = handler; },
    reportValidity() { return this.valid; },
  }]));
  const requests = [];
  const script = fs.readFileSync(`${__dirname}/index.html`, 'utf8').split('<script>')[1].split('</script>')[0];
  vm.runInNewContext(script, {
    URLSearchParams,
    document: {
      querySelector: selector => elements[selector.slice(1)],
      querySelectorAll: selector => selector === 'input'
        ? [elements['week-offset'], elements['month-offset']] : Object.values(elements),
    },
    fetch: async url => { requests.push(url); return { ok: true, text: async () => 'recap' }; },
  });
  return { elements, requests };
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
