s.boot;

MIDIClient.init;
MIDIIn.connectAll;
MIDIClient.destinations;
(
var midi_out, mapper, param, eq, pause, micropause;
var up, down;
var note_on, note_off;
var cutoff, res, attack, peak, decay, sustain, release, f_attack, f_peak, f_decay, f_sustain, f_release, loop_start, loop_end, key_tracking, osc_mix, osc2_detune; // 17
var last, counts;
last = Array.fill(17, {-1});
counts = Array.fill(17, {0});

up = Int8Array[0xF0,0x0F,0x01,0x01,0x0E,0x7F,0xF7];
down = Int8Array[0xF0,0x0F,0x01,0x01,0x0F,0x7F,0xF7];

cutoff = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x03,0x06,0x7F,0xF7];
res = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x03,0x07,0x7F,0xF7];

attack = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x05,0x00,0x7F,0xF7];
peak = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x05,0x01,0x7F,0xF7];
decay = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x05,0x02,0x7F,0xF7];
sustain = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x05,0x03,0x7F,0xF7];
release = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x05,0x04,0x7F,0xF7];

f_attack = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x04,0x00,0x7F,0xF7];
f_peak = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x04,0x01,0x7F,0xF7];
f_decay = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x04,0x02,0x7F,0xF7];
f_sustain = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x04,0x03,0x7F,0xF7];
f_release = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x04,0x04,0x7F,0xF7];

loop_start = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x06,0x02,0x7F,0xF7];
loop_end = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x06,0x03,0x7F,0xF7];

key_tracking = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x03,0x08,0x7F,0xF7];

osc2_detune = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x03,0x03,0x7F,0xF7];
osc_mix = Int8Array[0xF0,0x0F,0x01,0x01,0x0C,0x03,0x04,0x7F,0xF7];

param = cutoff;

midi_out = MIDIOut.newByName("Audio Kontrol 1 Out", "Audio Kontrol 1 Out");
midi_out.latency(0);

mapper = {arg prev, now;
	var diff, out;
	diff = now - prev;
	if (diff < 0, {out = down}, {out = up});
	out;
};

eq = {arg one, two;
	var equal;
	equal = true;
	for (0, one.size - 1, {arg i; if(one[i] == two[i], {}, {equal = false});});
	equal;
};

pause = {
	var dummy;
	dummy = 0;
	for (0, 1e25, {dummy = dummy + 1; micropause;});
};

micropause = {
	var dummy = 0;
	for (0, 1e25, {dummy = dummy + 1;});
};

MIDIdef.cc(\cutoff, {
	arg a;
	if (last[0] != a, {
		if (eq.value(param, cutoff), {}, {midi_out.sysex(cutoff); param = cutoff;});
		counts[0] = counts[0] + 1;
		if (counts[0] == 1, {midi_out.sysex(mapper.value(last[0], a)); last[0] = a; counts[0] = 0; pause;});
	});
},
ccNum: 29); // frequency

MIDIdef.cc(\res, {
	arg a;
	if (last[1] != a, {
		if (eq.value(param, res), {}, {midi_out.sysex(res); param = res;});
		counts[1] = counts[1] + 1;
		if (counts[1] == 2, {midi_out.sysex(mapper.value(last[1], a)); last[1] = a; counts[1] = 0; pause;});
	});
},
ccNum: 79); // resonance

MIDIdef.cc(\attack, {
	arg a;
	if (last[2] != a, {
		if (eq.value(param, attack), {}, {midi_out.sysex(attack); param = attack;});
		counts[2] = counts[2] + 1;
		if (counts[2] == 3, {midi_out.sysex(mapper.value(last[2], a)); last[2] = a; counts[2] = 0; pause;});
	});
},
ccNum: 86); // amp attack

MIDIdef.cc(\peak, {
	arg a;
	if (last[10] != a, {
		counts[10] = counts[10] + 1;
		if (eq.value(param, peak), {}, {midi_out.sysex(peak); param = peak;});
		if (counts[10] == 3, {midi_out.sysex(mapper.value(last[10], a)); last[10] = a; counts[10] = 0; pause;});
	});
},
ccNum: 82); // LFO 1 fade time

MIDIdef.cc(\decay, {
	arg a;
	if (last[4] != a, {
		counts[4] = counts[4] + 1;
		if (eq.value(param, decay), {}, {midi_out.sysex(decay); param = decay;});
		if (counts[4] == 3, {midi_out.sysex(mapper.value(last[4], a)); last[4] = a; counts[4] = 0; pause;});
	});
},
ccNum: 87); // amp decay

MIDIdef.cc(\sustain, {
	arg a;
	if (last[5] != a, {
		counts[5] = counts[5] + 1;
		if (eq.value(param, sustain), {}, {midi_out.sysex(sustain); param = sustain;});
		if (counts[5] == 3, {midi_out.sysex(mapper.value(last[5], a)); last[5] = a; counts[5] = 0; pause;});
	});
},
ccNum: 88); // amp sustain

MIDIdef.cc(\release, {
	arg a;
	if (last[3] != a, {
		counts[3] = counts[3] + 1;
		if (eq.value(param, release), {}, {midi_out.sysex(release); param = release;});
		if (counts[3] == 3, {midi_out.sysex(mapper.value(last[3], a)); last[3] = a; counts[3] = 0; pause;});
	});
},
ccNum: 89); // amp release

MIDIdef.cc(\f_attack, {
	arg a;
	if (last[6] != a, {
		counts[6] = counts[6] + 1;
		if (eq.value(param, f_attack), {}, {midi_out.sysex(f_attack); param = f_attack;});
		if (counts[6] == 3, {midi_out.sysex(mapper.value(last[6], a)); last[6] = a; counts[6] = 0; pause;});
	});
},
ccNum: 90); // env 1 attack

MIDIdef.cc(\f_peak, {
	arg a;
	if (last[11] != a, {
		counts[11] = counts[11] + 1;
		if (eq.value(param, f_peak), {}, {midi_out.sysex(f_peak); param = f_peak;});
		if (counts[11] == 3, {midi_out.sysex(mapper.value(last[11], a)); last[11] = a; counts[11] = 0; pause;});
	});
},
ccNum: 85); // LFO 2 fade time

MIDIdef.cc(\f_decay, {
	arg a;
	if (last[7] != a, {
		counts[7] = counts[7] + 1;
		if (eq.value(param, f_decay), {}, {midi_out.sysex(f_decay); param = f_decay;});
		if (counts[7] == 3, {midi_out.sysex(mapper.value(last[7], a)); last[7] = a; counts[7] = 0; pause;});
	});
},
ccNum: 91); // env 1 decay

MIDIdef.cc(\f_sustain, {
	arg a;
	if (last[8] != a, {
		counts[8] = counts[8] + 1;
		if (eq.value(param, f_sustain), {}, {midi_out.sysex(f_sustain); param = f_sustain;});
		if (counts[8] == 3, {midi_out.sysex(mapper.value(last[8], a)); last[8] = a; counts[8] = 0; pause;});
	});
},
ccNum: 92); // env 1 sustain

MIDIdef.cc(\f_release, {
	arg a;
	if (last[9] != a, {
		counts[9] = counts[9] + 1;
		if (eq.value(param, f_release), {}, {midi_out.sysex(f_release); param = f_release;});
		if (counts[9] == 3, {midi_out.sysex(mapper.value(last[9], a)); last[9] = a; counts[9] = 0; pause;});
	});
},
ccNum: 93); // env 1 release

MIDIdef.cc(\loop_start, {
	arg a;
	if (last[12] != a, {
		counts[12] = counts[12] + 1;
		if (eq.value(param, loop_start), {}, {midi_out.sysex(loop_start); param = loop_start;});
		if (counts[12] == 1, {midi_out.sysex(mapper.value(last[12], a)); pause; midi_out.sysex(mapper.value(last[12], a)); last[12] = a; counts[12] = 0; pause;});
	});
},
ccNum: 25); // oscillator 3 level

MIDIdef.cc(\loop_end, {
	arg a;
	if (last[13] != a, {
		counts[13] = counts[13] + 1;
		if (eq.value(param, loop_end), {}, {midi_out.sysex(loop_end); param = loop_end;});
		if (counts[13] == 1, {midi_out.sysex(mapper.value(last[13], a)); pause; midi_out.sysex(mapper.value(last[13], a)); last[13] = a; counts[13] = 0; pause;});
	});
},
ccNum: 27); // noise level

MIDIdef.cc(\key_tracking, {
	arg a;
	if (last[14] != a, {
		counts[14] = counts[14] + 1;
		if (eq.value(param, key_tracking), {}, {midi_out.sysex(key_tracking); param = key_tracking;});
		if (counts[14] == 28, {midi_out.sysex(mapper.value(last[14], a)); last[14] = a; counts[14] = 0; pause;});
	});
},
ccNum: 75); // key tracking

MIDIdef.cc(\osc_mix, {
	arg a;
	if (last[15] != a, {
		counts[15] = counts[15] + 1;
		if (eq.value(param, osc_mix), {}, {midi_out.sysex(osc_mix); param = osc_mix;});
		if (counts[15] == 2, {midi_out.sysex(mapper.value(last[15], a)); last[15] = a; counts[15] = 0; pause;});
	});
},
ccNum: 23); // oscillator 1 level

MIDIdef.cc(\osc2_detune, {
	arg a;
	if (last[16] != a, {
		counts[16] = counts[16] + 1;
		if (eq.value(param, osc2_detune), {}, {midi_out.sysex(osc2_detune); param = osc2_detune;});
		if (counts[16] == 1, {midi_out.sysex(mapper.value(last[16], a)); last[16] = a; counts[16] = 0; pause;});
	});
},
ccNum: 24); // oscillator 2 level

MIDIdef.noteOn(\note_on, {arg val, num, chan, src; midi_out.noteOn(chan, num, val);}, nil, nil, nil);
MIDIdef.noteOff(\note_off, {arg val, num, chan, src; midi_out.noteOff(chan, num, val);}, nil, nil, nil);

)