s.boot;

~wass = Buffer.read(s, "/Users/alex/Music/Projects/Junto/0424 - Fluctuating Rhythm/Wasserflut.wav");
~tube_exc = Buffer.read(s, "/Users/alex/Music/Projects/Junto/0424 - Fluctuating Rhythm/tube exc.wav");
~tube_gate = Buffer.read(s, "/Users/alex/Music/Projects/Junto/0424 - Fluctuating Rhythm/tube HP gated 2.wav");

(
a = SynthDef(\help_beattrack, { |out, pregain=0.7, pipegain=0.1, hipegain=0.02, lock=0, lag1=7.385, lag2=0.4615 |
    var in, fftL, fftR, tube;
    var trackbL, trackhL, trackqL, tempoL, tempadjL;
    var trackbR, trackhR, trackqR, tempoR, tempadjR;
    var dTL, dTR;
	var inmodL, inmodL2, inmodL3, inmodL4, ratemodL, ratemodL2, ratemodL3, ratemodL4;
	var inmodR, inmodR2, inmodR3, inmodR4, ratemodR, ratemodR2, ratemodR3, ratemodR4;
	var premix, allDone;

    in = PlayBuf.ar(2,~tube_gate,BufRateScale.kr(~tube_gate),1,0,1);

	tube = PlayBuf.ar(2, ~tube_exc, BufRateScale.kr(~tube_exc), 1, 0, 1);

	fftL = FFT(LocalBuf(1024), in[0]);
	fftR = FFT(LocalBuf(1024), in[1]);

    #trackbL, trackhL, trackqL, tempoL = BeatTrack.kr(fftL, lock);
    #trackbR, trackhR, trackqR, tempoR = BeatTrack.kr(fftR, lock);

	tempadjL = (tempoL==nil).if({60/65},{tempoL/2 * 60/65});
	tempadjR = (tempoR==nil).if({60/65},{tempoR/2 * 60/65});

	dTL = Changed.kr(tempadjL);
	dTR = Changed.kr(tempadjR);

	[tempadjL, tempadjR].poll(dTL | dTR);

	ratemodL = VarLag.kr(tempadjL, lag1, warp: \cub);
	ratemodL2 = VarLag.kr(tempadjL, lag1, warp: \exp);
	ratemodL3 = VarLag.kr(tempadjL, lag2, warp: \lin);
	ratemodL4 = VarLag.kr(tempadjL, lag2, warp: \exp);

	ratemodR = VarLag.kr(tempadjR, lag1, warp: \cub);
	ratemodR2 = VarLag.kr(tempadjR, lag1, warp: \exp);
	ratemodR3 = VarLag.kr(tempadjR, lag2, warp: \lin);
	ratemodR4 = VarLag.kr(tempadjR, lag2, warp: \exp);


    inmodL = PlayBuf.ar(2,~wass,ratemodL*BufRateScale.kr(~wass),1,0,0);
    inmodL2 = PlayBuf.ar(2,~wass,ratemodL2*BufRateScale.kr(~wass),1,0,0);
    inmodL3 = PlayBuf.ar(2,~wass,ratemodL3*BufRateScale.kr(~wass),1,0,0);
    inmodL4 = PlayBuf.ar(2,~wass,ratemodL4*BufRateScale.kr(~wass),1,0,0);

    inmodR = PlayBuf.ar(2,~wass,ratemodR*BufRateScale.kr(~wass),1,0,0);
    inmodR2 = PlayBuf.ar(2,~wass,ratemodR2*BufRateScale.kr(~wass),1,0,0);
    inmodR3 = PlayBuf.ar(2,~wass,ratemodR3*BufRateScale.kr(~wass),1,0,0);
    inmodR4 = PlayBuf.ar(2,~wass,ratemodR4*BufRateScale.kr(~wass),1,0,0);

	allDone = [Done.kr(inmodL), Done.kr(inmodL2), Done.kr(inmodL3), Done.kr(inmodL4), Done.kr(inmodR), Done.kr(inmodR2), Done.kr(inmodR3), Done.kr(inmodR4)].sum;
	allDone.poll(Changed.kr(allDone));
	FreeSelf.kr(allDone-7.5);

	premix = pregain*(Pan2.ar(inmodL, -0.9, 0.707) + Pan2.ar(inmodL2, -0.2) + Pan2.ar(inmodL3, -0.4) + Pan2.ar(inmodL4, -0.05) + Pan2.ar(inmodR, 0.9, 0.707) + Pan2.ar(inmodR2, 0.2) + Pan2.ar(inmodR3, 0.4) + Pan2.ar(inmodR4, 0.05));

	Out.ar(out, premix+(pipegain*tube)+(hipegain*in))
}).play;
s.record
)
s.stopRecording;

a.set(\lag1, 8.0 * 60/65);
a.set(\lag2, 1.0 * 60/65);
a.set(\pregain, 0.7);
a.set(\pipegain, 0.1);
a.set(\hipegain, 0.02);