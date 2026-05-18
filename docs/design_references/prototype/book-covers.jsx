// BookCover — typographic book covers for the LSM library.
// Original designs, not reproductions of publishers' artwork.

function BookCover({ book, size = 'lg' }) {
  const scale = size === 'sm' ? 0.55 : 1;
  const id = (book && book.id) || 'default';
  const Render = COVER_RENDERERS[id] || COVER_RENDERERS.default;
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative', overflow: 'hidden',
      fontFamily: '"Geist", system-ui, sans-serif',
      boxShadow: 'inset 0 0 0 1px rgba(0,0,0,0.08)',
    }}>
      <Render book={book} scale={scale} />
    </div>
  );
}

// helpers
const monoLabel = (txt, color, scale) => (
  <div style={{
    fontFamily: '"Geist Mono", monospace',
    fontSize: 8 * scale, letterSpacing: 1.4, textTransform: 'uppercase',
    color, opacity: 0.7,
  }}>{txt}</div>
);

const COVER_RENDERERS = {
  // ─── Le Petit Prince ────────────────────────────────────────
  prince: ({ book, scale }) => (
    <div style={{
      position: 'absolute', inset: 0,
      background: 'linear-gradient(180deg, #1A3454 0%, #2A4D74 55%, #6B5A8F 80%, #C28B4E 100%)',
      color: '#F4E9C1',
      padding: 8 * scale, boxSizing: 'border-box',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* stars */}
      <svg style={{ position: 'absolute', inset: 0 }} width="100%" height="100%">
        <circle cx="14%" cy="22%" r={1 * scale} fill="#F4E9C1" opacity="0.8"/>
        <circle cx="82%" cy="18%" r={1.5 * scale} fill="#F4E9C1" opacity="0.9"/>
        <circle cx="68%" cy="40%" r={0.8 * scale} fill="#F4E9C1" opacity="0.6"/>
        <circle cx="22%" cy="46%" r={1 * scale} fill="#F4E9C1" opacity="0.5"/>
        <circle cx="92%" cy="32%" r={0.8 * scale} fill="#F4E9C1" opacity="0.4"/>
      </svg>
      {/* small planet with figure */}
      <div style={{ position: 'absolute', left: '50%', top: '38%', transform: 'translate(-50%, -50%)' }}>
        <svg width={48 * scale} height={48 * scale} viewBox="0 0 48 48">
          <circle cx="24" cy="32" r="14" fill="#C28B4E" opacity="0.85"/>
          <ellipse cx="24" cy="32" rx="20" ry="3" fill="#C28B4E" opacity="0.35"/>
          {/* tiny stick figure on planet */}
          <circle cx="24" cy="14" r="2" fill="#F4E9C1"/>
          <line x1="24" y1="16" x2="24" y2="22" stroke="#F4E9C1" strokeWidth="1.4" strokeLinecap="round"/>
          <line x1="24" y1="18" x2="20" y2="20" stroke="#F4E9C1" strokeWidth="1.2" strokeLinecap="round"/>
          <line x1="24" y1="18" x2="28" y2="20" stroke="#F4E9C1" strokeWidth="1.2" strokeLinecap="round"/>
        </svg>
      </div>
      {/* title bottom */}
      <div style={{ marginTop: 'auto', position: 'relative', zIndex: 2 }}>
        <div style={{
          fontSize: 13 * scale, fontWeight: 400, letterSpacing: -0.4, lineHeight: 1.05,
          fontStyle: 'italic',
        }}>Le Petit<br/>Prince</div>
        <div style={{ marginTop: 4 * scale }}>
          {monoLabel('A. de Saint-Exupéry', '#F4E9C1', scale)}
        </div>
      </div>
    </div>
  ),

  // ─── Hayy Ibn Yaqdhan ───────────────────────────────────────
  hayy: ({ book, scale }) => (
    <div style={{
      position: 'absolute', inset: 0,
      background: 'linear-gradient(160deg, #E4CFA8 0%, #C7A074 55%, #9C7045 100%)',
      color: '#2A1A0A',
      padding: 8 * scale, boxSizing: 'border-box',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* moroccan geometric motif */}
      <svg
        viewBox="0 0 60 60"
        style={{ position: 'absolute', top: '18%', left: '50%', transform: 'translateX(-50%)' }}
        width={54 * scale} height={54 * scale}
      >
        <g stroke="#2A1A0A" strokeWidth="0.8" fill="none">
          <polygon points="30,4 56,30 30,56 4,30" />
          <polygon points="30,12 48,30 30,48 12,30" />
          <polygon points="30,20 40,30 30,40 20,30" />
          <circle cx="30" cy="30" r="2" fill="#2A1A0A"/>
          <line x1="30" y1="4" x2="30" y2="56"/>
          <line x1="4" y1="30" x2="56" y2="30"/>
        </g>
      </svg>
      {/* arabic title */}
      <div style={{
        position: 'absolute', top: '54%', left: 0, right: 0, textAlign: 'center',
        fontFamily: '"Noto Kufi Arabic", serif', fontSize: 12 * scale, color: '#2A1A0A',
        direction: 'rtl', opacity: 0.6,
      }}>حي بن يقظان</div>
      {/* title bottom */}
      <div style={{ marginTop: 'auto', position: 'relative', zIndex: 2 }}>
        <div style={{
          fontSize: 12 * scale, fontWeight: 500, letterSpacing: -0.3, lineHeight: 1.05,
        }}>Hayy Ibn<br/>Yaqdhan</div>
        <div style={{ marginTop: 4 * scale }}>
          {monoLabel('Ibn Tufayl · XIIᵉ s.', '#2A1A0A', scale)}
        </div>
      </div>
    </div>
  ),

  // ─── Souffles ───────────────────────────────────────────────
  souffles: ({ book, scale }) => (
    <div style={{
      position: 'absolute', inset: 0,
      background: '#7A1925',
      color: '#F4ECD8',
      padding: 8 * scale, boxSizing: 'border-box',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* abstract breath lines */}
      <svg
        viewBox="0 0 100 140"
        preserveAspectRatio="none"
        style={{ position: 'absolute', inset: 0, opacity: 0.45 }}
        width="100%" height="100%"
      >
        <path d="M-10 50 Q30 30 60 60 T130 50" stroke="#F4ECD8" strokeWidth="0.6" fill="none"/>
        <path d="M-10 70 Q30 50 60 80 T130 70" stroke="#F4ECD8" strokeWidth="0.6" fill="none"/>
        <path d="M-10 90 Q40 70 70 100 T130 90" stroke="#F4ECD8" strokeWidth="0.6" fill="none"/>
        <path d="M-10 110 Q35 95 65 120 T130 110" stroke="#F4ECD8" strokeWidth="0.6" fill="none"/>
      </svg>
      {/* horizontal accent rule */}
      <div style={{
        position: 'absolute', top: '30%', left: 8 * scale, right: 8 * scale,
        height: 1, background: '#F4ECD8', opacity: 0.7,
      }}/>
      {/* mono mark top */}
      <div style={{ position: 'relative', zIndex: 2 }}>
        {monoLabel('Nº 01 · 1966', '#F4ECD8', scale)}
      </div>
      {/* title bottom */}
      <div style={{ marginTop: 'auto', position: 'relative', zIndex: 2 }}>
        <div style={{
          fontSize: 22 * scale, fontWeight: 600, letterSpacing: -1, lineHeight: 0.95,
          textTransform: 'lowercase', fontStyle: 'italic',
        }}>souffles</div>
        <div style={{ marginTop: 4 * scale }}>
          {monoLabel('A. Laâbi', '#F4ECD8', scale)}
        </div>
      </div>
    </div>
  ),

  // ─── default fallback ───────────────────────────────────────
  default: ({ book, scale }) => (
    <div style={{
      position: 'absolute', inset: 0,
      background: '#E8E1D5', color: '#1B1A17',
      padding: 8 * scale, boxSizing: 'border-box',
      display: 'flex', flexDirection: 'column', justifyContent: 'flex-end',
    }}>
      <div style={{ fontSize: 13 * scale, fontWeight: 500, lineHeight: 1.1 }}>{book && book.t}</div>
      <div style={{ marginTop: 4 * scale }}>{monoLabel(book && book.a, '#1B1A17', scale)}</div>
    </div>
  ),
};

Object.assign(window, { BookCover });
