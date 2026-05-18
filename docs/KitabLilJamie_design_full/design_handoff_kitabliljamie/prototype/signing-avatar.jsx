// SigningAvatar — animated stylised figure that signs (loops indefinitely)
// Uses SMIL <animateTransform> on jointed limbs. No external assets.
//
// Props:
//   variant : 'open' | 'heart' | 'spell' | 'point' | 'read' | 'wave' | 'poem' | 'think' | 'full'
//   bg      : background color of the stage
//   accent  : accent color (used for a subtle glow)
//   skin    : skin tone hex
//   cloth   : clothing/torso color
//   scale   : 1 = normal, larger = zoom in
//   dark    : invert palette
//
// Each variant defines keyframes for both shoulders + both elbows.

const SIGN_PALETTES = {
  cream: { bg: '#ECE5D6', glow: '#B8552D', skin: '#9A6E4A', cloth: '#1B1A17', shadow: 'rgba(40,28,12,0.18)' },
  warm:  { bg: '#E8DEC8', glow: '#B8552D', skin: '#A4754E', cloth: '#2A211A', shadow: 'rgba(40,28,12,0.2)' },
  cool:  { bg: '#DFDDD2', glow: '#5B6E5A', skin: '#8A6648', cloth: '#1B1A17', shadow: 'rgba(20,20,20,0.18)' },
  dusk:  { bg: '#3A342D', glow: '#B8552D', skin: '#B98A66', cloth: '#0E0C0A', shadow: 'rgba(0,0,0,0.4)' },
  dark:  { bg: '#1B1A17', glow: '#B8552D', skin: '#B98A66', cloth: '#0E0C0A', shadow: 'rgba(0,0,0,0.5)' },
};

// joint poses — each value is "angle cx cy" for SVG rotate()
// shoulders pivot at (50,88) left, (110,88) right
// elbows pivot at (50,130) left (relative to unrotated coords), (110,130) right
const SHL = '50 88',  SHR = '110 88',  ELL = '50 130',  ELR = '110 130';

const SIGN_VARIANTS = {
  // both hands open outward like opening a book
  open: {
    dur: '2.8s',
    shoulderL: ['-10 ' + SHL, '-40 ' + SHL, '-50 ' + SHL, '-30 ' + SHL, '-10 ' + SHL],
    shoulderR: [ '10 ' + SHR,  '40 ' + SHR,  '50 ' + SHR,  '30 ' + SHR,  '10 ' + SHR],
    elbowL:    ['-20 ' + ELL, '-10 ' + ELL,   '0 ' + ELL, '-15 ' + ELL, '-20 ' + ELL],
    elbowR:    [ '20 ' + ELR,  '10 ' + ELR,   '0 ' + ELR,  '15 ' + ELR,  '20 ' + ELR],
  },
  // one hand to chest (heart)
  heart: {
    dur: '3.2s',
    shoulderL: ['-15 ' + SHL, '15 ' + SHL,  '30 ' + SHL, '20 ' + SHL,  '-15 ' + SHL],
    shoulderR: [ '15 ' + SHR, '10 ' + SHR,   '5 ' + SHR, '12 ' + SHR,   '15 ' + SHR],
    elbowL:    ['-30 ' + ELL,'-80 ' + ELL, '-95 ' + ELL,'-70 ' + ELL,  '-30 ' + ELL],
    elbowR:    [ '20 ' + ELR, '25 ' + ELR,  '20 ' + ELR, '15 ' + ELR,   '20 ' + ELR],
  },
  // finger-spelling: both hands wiggle in place near chest
  spell: {
    dur: '1.6s',
    shoulderL: ['-25 ' + SHL, '-30 ' + SHL, '-25 ' + SHL, '-30 ' + SHL, '-25 ' + SHL],
    shoulderR: [ '25 ' + SHR,  '20 ' + SHR,  '25 ' + SHR,  '20 ' + SHR,  '25 ' + SHR],
    elbowL:    ['-60 ' + ELL, '-75 ' + ELL, '-55 ' + ELL, '-70 ' + ELL, '-60 ' + ELL],
    elbowR:    [ '60 ' + ELR,  '45 ' + ELR,  '65 ' + ELR,  '50 ' + ELR,  '60 ' + ELR],
  },
  // point and adjust — right hand sweeps
  point: {
    dur: '3s',
    shoulderL: ['-10 ' + SHL, '-15 ' + SHL, '-10 ' + SHL, '-15 ' + SHL, '-10 ' + SHL],
    shoulderR: [ '35 ' + SHR,  '60 ' + SHR,  '80 ' + SHR,  '50 ' + SHR,  '35 ' + SHR],
    elbowL:    ['-30 ' + ELL, '-30 ' + ELL, '-30 ' + ELL, '-30 ' + ELL, '-30 ' + ELL],
    elbowR:    [ '10 ' + ELR,  '15 ' + ELR,  '20 ' + ELR,  '15 ' + ELR,  '10 ' + ELR],
  },
  // reading gesture — both hands cradle, slight nod
  read: {
    dur: '2.6s',
    shoulderL: ['-35 ' + SHL, '-40 ' + SHL, '-32 ' + SHL, '-40 ' + SHL, '-35 ' + SHL],
    shoulderR: [ '35 ' + SHR,  '40 ' + SHR,  '32 ' + SHR,  '40 ' + SHR,  '35 ' + SHR],
    elbowL:    ['-65 ' + ELL, '-50 ' + ELL, '-70 ' + ELL, '-55 ' + ELL, '-65 ' + ELL],
    elbowR:    [ '65 ' + ELR,  '50 ' + ELR,  '70 ' + ELR,  '55 ' + ELR,  '65 ' + ELR],
  },
  // gentle wave
  wave: {
    dur: '2s',
    shoulderL: ['-10 ' + SHL, '-15 ' + SHL, '-10 ' + SHL, '-15 ' + SHL, '-10 ' + SHL],
    shoulderR: [ '60 ' + SHR,  '70 ' + SHR,  '55 ' + SHR,  '70 ' + SHR,  '60 ' + SHR],
    elbowL:    ['-25 ' + ELL, '-25 ' + ELL, '-25 ' + ELL, '-25 ' + ELL, '-25 ' + ELL],
    elbowR:    ['-60 ' + ELR, '-75 ' + ELR, '-50 ' + ELR, '-75 ' + ELR, '-60 ' + ELR],
  },
  // poetic sweep — both arms wide and slow
  poem: {
    dur: '4s',
    shoulderL: ['-20 ' + SHL, '-60 ' + SHL, '-80 ' + SHL, '-40 ' + SHL, '-20 ' + SHL],
    shoulderR: [ '20 ' + SHR,  '60 ' + SHR,  '80 ' + SHR,  '40 ' + SHR,  '20 ' + SHR],
    elbowL:    ['-10 ' + ELL, '-15 ' + ELL,  '-5 ' + ELL, '-15 ' + ELL, '-10 ' + ELL],
    elbowR:    [ '10 ' + ELR,  '15 ' + ELR,   '5 ' + ELR,  '15 ' + ELR,  '10 ' + ELR],
  },
  // thinking — one hand near chin
  think: {
    dur: '3.4s',
    shoulderL: ['-15 ' + SHL, '-10 ' + SHL, '-15 ' + SHL, '-10 ' + SHL, '-15 ' + SHL],
    shoulderR: [ '20 ' + SHR,  '40 ' + SHR,  '45 ' + SHR,  '38 ' + SHR,  '20 ' + SHR],
    elbowL:    ['-25 ' + ELL, '-25 ' + ELL, '-25 ' + ELL, '-25 ' + ELL, '-25 ' + ELL],
    elbowR:    ['-80 ' + ELR,'-110 ' + ELR,'-115 ' + ELR,'-105 ' + ELR, '-80 ' + ELR],
  },
};

function SigningAvatar({
  variant = 'open',
  palette = 'cream',
  showLabel = false,
  label = 'AVATAR · LSM',
  glow = true,
  delay = '0s',
}) {
  const pal = SIGN_PALETTES[palette] || SIGN_PALETTES.cream;
  const v = SIGN_VARIANTS[variant] || SIGN_VARIANTS.open;
  const keyTimes = '0; 0.25; 0.5; 0.75; 1';

  const animRot = (vals) => (
    <animateTransform
      attributeName="transform"
      type="rotate"
      values={vals.join(';')}
      keyTimes={keyTimes}
      dur={v.dur}
      begin={delay}
      repeatCount="indefinite"
      calcMode="spline"
      keySplines="0.4 0 0.6 1; 0.4 0 0.6 1; 0.4 0 0.6 1; 0.4 0 0.6 1"
    />
  );

  // Subtle head bob
  const headBob = (
    <animateTransform
      attributeName="transform"
      type="translate"
      values="0 0; 0 -2; 0 0; 0 -1; 0 0"
      keyTimes={keyTimes}
      dur={v.dur}
      begin={delay}
      repeatCount="indefinite"
    />
  );

  return (
    <div style={{
      position: 'relative', width: '100%', height: '100%',
      background: pal.bg, overflow: 'hidden',
    }}>
      {/* warm glow under figure */}
      {glow && (
        <div style={{
          position: 'absolute', inset: 0,
          background: `radial-gradient(ellipse at 50% 78%, ${pal.glow}22 0%, transparent 60%)`,
        }} />
      )}

      <svg
        viewBox="0 0 160 240"
        preserveAspectRatio="xMidYMax meet"
        style={{
          position: 'absolute', inset: 0, width: '100%', height: '100%',
          filter: `drop-shadow(0 8px 16px ${pal.shadow})`,
        }}
      >
        {/* ground shadow */}
        <ellipse cx="80" cy="222" rx="38" ry="5" fill={pal.shadow} />

        {/* head + neck (with bob) */}
        <g>
          {headBob}
          <ellipse cx="80" cy="48" rx="26" ry="30" fill={pal.skin} />
          {/* simple face accents */}
          <circle cx="71" cy="48" r="2" fill={pal.cloth} opacity="0.55" />
          <circle cx="89" cy="48" r="2" fill={pal.cloth} opacity="0.55" />
          <path d="M73 60 Q80 64 87 60" stroke={pal.cloth} strokeWidth="1.4" strokeLinecap="round" fill="none" opacity="0.5" />
          <rect x="73" y="74" width="14" height="10" fill={pal.skin} />
        </g>

        {/* torso */}
        <path
          d="M44 88 Q44 84 54 82 L106 82 Q116 84 116 88 L120 200 Q120 208 112 208 L48 208 Q40 208 40 200 Z"
          fill={pal.cloth}
        />
        {/* shoulder seams */}
        <line x1="80" y1="84" x2="80" y2="200" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />

        {/* LEFT arm — shoulder group rotates around (50,88) */}
        <g>
          {animRot(v.shoulderL)}
          {/* upper arm */}
          <line x1="50" y1="88" x2="50" y2="130" stroke={pal.cloth} strokeWidth="22" strokeLinecap="round" />
          {/* elbow group */}
          <g>
            {animRot(v.elbowL)}
            <line x1="50" y1="130" x2="50" y2="170" stroke={pal.skin} strokeWidth="18" strokeLinecap="round" />
            <circle cx="50" cy="174" r="11" fill={pal.skin} />
            {/* tiny finger detail */}
            <line x1="50" y1="178" x2="50" y2="186" stroke={pal.skin} strokeWidth="4" strokeLinecap="round" />
          </g>
        </g>

        {/* RIGHT arm */}
        <g>
          {animRot(v.shoulderR)}
          <line x1="110" y1="88" x2="110" y2="130" stroke={pal.cloth} strokeWidth="22" strokeLinecap="round" />
          <g>
            {animRot(v.elbowR)}
            <line x1="110" y1="130" x2="110" y2="170" stroke={pal.skin} strokeWidth="18" strokeLinecap="round" />
            <circle cx="110" cy="174" r="11" fill={pal.skin} />
            <line x1="110" y1="178" x2="110" y2="186" stroke={pal.skin} strokeWidth="4" strokeLinecap="round" />
          </g>
        </g>
      </svg>

      {showLabel && (
        <div style={{
          position: 'absolute', top: 8, left: 8,
          background: 'rgba(27,26,23,0.78)', color: '#F6F2EB',
          fontFamily: '"Geist Mono", monospace', fontSize: 8, letterSpacing: 0.6,
          padding: '3px 6px', borderRadius: 99,
          display: 'flex', alignItems: 'center', gap: 5,
        }}>
          <span style={{
            width: 4, height: 4, borderRadius: 99, background: pal.glow,
            animation: 'sa-pulse 1.2s ease-in-out infinite',
          }}/>
          {label}
        </div>
      )}

      <style>{`
        @keyframes sa-pulse {
          0%, 100% { opacity: 0.5; transform: scale(0.9); }
          50% { opacity: 1; transform: scale(1.2); }
        }
      `}</style>
    </div>
  );
}

Object.assign(window, { SigningAvatar });
