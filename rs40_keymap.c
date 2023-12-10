// Copyright 2023 Audite Marlow (@auditemarlow)
// SPDX-License-Identifier: GPL-3.0

// Notes (Arnau):
// - place this file at `qmk_firmware/keyboards/kj_modify/rs40/keymaps/default/keymap.c`
// - build with `make kj_modify/rs40:default`
// - flash with `make kj_modify/rs40:default:flash`
// In order to flash, plug the keyboard while having pressed the 0,0 key (ESC/Tab) to enter the flash mode.

#include QMK_KEYBOARD_H

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [0] = LAYOUT(
        KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,    KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSPC,
        KC_LCTL, KC_A,    KC_S,    KC_D,    KC_F,    KC_G,    KC_H,    KC_J,    KC_K,    KC_L,             KC_QUOT,
        KC_LSFT,          KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,    KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_RSFT,
        KC_LCTL, KC_LGUI, MO(1),          KC_SPC,                    KC_ENT,             MO(2), KC_RALT, KC_SLSH
    ),
	[1] = LAYOUT(
		KC_ESC,   KC_1,    KC_2,        KC_3,   KC_4,    KC_5,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0,  KC_DEL,
		KC_LCTL,  KC_MUTE, KC_VOLD,  KC_VOLU,XXXXXXX, XXXXXXX,   KC_LEFT, KC_DOWN, KC_UP, KC_RIGHT,         XXXXXXX,
		KC_LSFT,          _______,  _______, _______, _______, _______, _______, _______, _______, _______, _______,
		_______,  KC_LGUI, _______,          KC_SPC,                   KC_ENT,          MO(3), KC_RALT, XXXXXXX
	),
	[2] = LAYOUT(
		KC_ESC,   KC_EXLM, KC_AT,  KC_HASH, KC_DLR,   KC_PERC, KC_CIRC, KC_AMPR, KC_ASTR, KC_LPRN, KC_RPRN,  KC_DEL,
		_______, _______, _______, _______, _______,  _______, KC_MINS, KC_EQL,  KC_LBRC, KC_RBRC,          KC_BSLS,
		_______,          _______, _______, _______,  _______, KC_UNDS, KC_PLUS, KC_LCBR, KC_RCBR, KC_PIPE, KC_TILD,
		_______, KC_LGUI, MO(3),          KC_SPC,                   KC_ENT,          XXXXXXX,  KC_SCLN, KC_GRV
	),
	[3] = LAYOUT(
		KC_ESC,    KC_F1,    KC_F2,    KC_F3,   KC_F4,   KC_F5,    KC_F6,    KC_F7,  KC_F8,    KC_F9,  KC_F10, KC_F11,
		XXXXXXX, XXXXXXX,  XXXXXXX,  XXXXXXX, XXXXXXX, XXXXXXX,  XXXXXXX,  XXXXXXX,XXXXXXX,  XXXXXXX,          KC_F12,
		XXXXXXX,           _______,  _______, _______, _______,  _______,  _______,_______,  _______, _______, _______,
		_______,  KC_LGUI, _______,          KC_SPC,                   KC_ENT,        XXXXXXX, KC_RALT, XXXXXXX
	),
};

