// KitabLilJamie — écrans
// 6 écrans : 3 module mal-voyants (Samia) + 3 module sourds (LSM)

const C = {
  bg: '#F6F2EB',
  card: '#FFFFFF',
  ink: '#1B1A17',
  ink2: '#3A352E',
  muted: '#827B6F',
  faint: '#B6AE9F',
  hair: '#E8E1D5',
  pill: '#EDE6D8',
  accent: '#B8552D',
  accentSoft: '#F1E2D6',
  dark: '#1B1A17',
};

const FS = {
  sans: '"Geist", -apple-system, system-ui, sans-serif',
  ar: '"Noto Kufi Arabic", "Geist", sans-serif',
  mono: '"Geist Mono", ui-monospace, monospace',
};

// ─── small atoms ───────────────────────────────────────────────

function Stripes({ angle = 45, color = '#E8E1D5', bg = '#F6F2EB', label, labelColor }) {
  return (
    <div style={{
      width: '100%', height: '100%', position: 'relative',
      background: `repeating-linear-gradient(${angle}deg, ${color} 0 1px, ${bg} 1px 10px)`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {label && (
        <span style={{
          fontFamily: FS.mono, fontSize: 10, letterSpacing: 0.5,
          textTransform: 'uppercase', color: labelColor || C.muted,
          background: bg, padding: '4px 8px', borderRadius: 2,
        }}>{label}</span>
      )}
    </div>
  );
}

function StatusBar({ dark }) {
  const c = dark ? '#fff' : C.ink;
  return (
    <div style={{
      height: 54, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '14px 28px 0', fontFamily: FS.sans, fontWeight: 600, fontSize: 15, color: c,
    }}>
      <span>9:41</span>
      <div style={{ display: 'flex', gap: 5, alignItems: 'center' }}>
        <svg width="16" height="10" viewBox="0 0 16 10"><rect x="0" y="6" width="2.5" height="4" rx="0.4" fill={c}/><rect x="4" y="4" width="2.5" height="6" rx="0.4" fill={c}/><rect x="8" y="2" width="2.5" height="8" rx="0.4" fill={c}/><rect x="12" y="0" width="2.5" height="10" rx="0.4" fill={c}/></svg>
        <svg width="22" height="11" viewBox="0 0 22 11"><rect x="0.5" y="0.5" width="19" height="10" rx="2.5" stroke={c} strokeOpacity="0.4" fill="none"/><rect x="2" y="2" width="16" height="7" rx="1" fill={c}/></svg>
      </div>
    </div>
  );
}

// ─── screen scaffold ───────────────────────────────────────────

function Phone({ children, dark, label }) {
  return (
    <div>
      <div style={{
        width: 360, height: 740, borderRadius: 44, overflow: 'hidden',
        background: dark ? C.dark : C.bg, position: 'relative',
        boxShadow: '0 30px 60px rgba(40,30,20,0.10), 0 0 0 8px #2a2520, 0 0 0 9px #0e0c0a',
        fontFamily: FS.sans, color: dark ? '#fff' : C.ink,
      }}>
        <StatusBar dark={dark} />
        {/* dynamic island */}
        <div style={{
          position: 'absolute', top: 10, left: '50%', transform: 'translateX(-50%)',
          width: 100, height: 28, borderRadius: 20, background: '#000',
        }} />
        <div style={{ height: 'calc(100% - 54px)', overflow: 'hidden', position: 'relative' }}>
          {children}
        </div>
        {/* home indicator */}
        <div style={{
          position: 'absolute', bottom: 8, left: '50%', transform: 'translateX(-50%)',
          width: 120, height: 4, borderRadius: 99,
          background: dark ? 'rgba(255,255,255,0.6)' : 'rgba(0,0,0,0.25)',
        }} />
      </div>
    </div>
  );
}

// ═══ SCREEN 1 — Accueil / choix du module ══════════════════════
function S1_Home({ nav = {} }) {
  return (
    <Phone>
      <div style={{ padding: '24px 28px 0', height: '100%', display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
          <div style={{ fontFamily: FS.mono, fontSize: 11, letterSpacing: 1.2, color: C.muted, textTransform: 'uppercase' }}>
            Kitab&nbsp;Lil&nbsp;Jamie
          </div>
          <div style={{ fontFamily: FS.ar, fontSize: 14, color: C.muted, direction: 'rtl' }}>كتاب للجميع</div>
        </div>

        <div style={{ marginTop: 60 }}>
          <h1 style={{
            fontFamily: FS.sans, fontWeight: 400, fontSize: 38, lineHeight: 1.1,
            margin: 0, letterSpacing: -1.2, textWrap: 'balance',
          }}>
            Chaque livre,<br/>
            <span style={{ color: C.accent, fontStyle: 'italic' }}>pour chacun.</span>
          </h1>
          <p style={{ marginTop: 18, fontSize: 15, lineHeight: 1.5, color: C.ink2, maxWidth: 260 }}>
            Choisissez votre porte d'entrée vers la bibliothèque.
          </p>
        </div>

        <div style={{ flex: 1 }} />

        <div style={{ display: 'flex', flexDirection: 'column', gap: 14, paddingBottom: 32 }}>
          <ModuleCard
            n="01"
            title="Samia"
            sub="Lecture vocale · arabe, français, darija"
            tag="Mal-voyants"
            primary
            onClick={() => nav.go && nav.go('audioLib')}
          />
          <ModuleCard
            n="02"
            title="SignBook"
            sub="Livres en langue des signes marocaine"
            tag="Sourds & malentendants"
            onClick={() => nav.go && nav.go('signHome')}
          />
        </div>
      </div>
    </Phone>
  );
}

function ModuleCard({ n, title, sub, tag, primary, onClick }) {
  return (
    <div onClick={onClick} style={{
      cursor: 'pointer', userSelect: 'none',
      background: primary ? C.ink : C.card,
      color: primary ? '#F6F2EB' : C.ink,
      borderRadius: 22, padding: '20px 22px',
      border: primary ? 'none' : `1px solid ${C.hair}`,
      display: 'flex', alignItems: 'center', gap: 16,
    }}>
      <div style={{
        fontFamily: FS.mono, fontSize: 11,
        color: primary ? 'rgba(246,242,235,0.5)' : C.faint,
      }}>{n}</div>
      <div style={{ flex: 1 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
          <div style={{ fontSize: 22, fontWeight: 500, letterSpacing: -0.4 }}>{title}</div>
          <div style={{
            fontFamily: FS.mono, fontSize: 9, letterSpacing: 0.8, textTransform: 'uppercase',
            color: primary ? 'rgba(246,242,235,0.55)' : C.muted,
          }}>· {tag}</div>
        </div>
        <div style={{
          fontSize: 13, marginTop: 2,
          color: primary ? 'rgba(246,242,235,0.7)' : C.muted,
        }}>{sub}</div>
      </div>
      <svg width="22" height="14" viewBox="0 0 22 14" fill="none">
        <path d="M1 7h19m0 0l-6-6m6 6l-6 6" stroke={primary ? '#F6F2EB' : C.ink} strokeWidth="1.4" strokeLinecap="round"/>
      </svg>
    </div>
  );
}

// ═══ SCREEN 2 — Bibliothèque audio (Samia) ═════════════════════
function S2_AudioLibrary({ nav = {} }) {
  const books = [
    { id: 'pain',    t: "Le Pain Nu",        a: "Mohamed Choukri",     d: "6h 12min", cat: "Roman",  color: '#B8552D', chapter: "Chapitre trois" },
    { id: 'sable',   t: "L'Enfant de Sable", a: "Tahar Ben Jelloun",   d: "4h 48min", cat: "Roman",  color: '#3D5141', chapter: "Chapitre un" },
    { id: 'tales',   t: "Moroccan Tales",    a: "Anthologie",          d: "2h 30min", cat: "Récits", color: '#2E3540', chapter: "Premier récit" },
    { id: 'passe',   t: "Le Passé Simple",   a: "Driss Chraïbi",       d: "7h 05min", cat: "Roman",  color: '#7A4D2B', chapter: "Première partie" },
  ];
  return (
    <Phone>
      <div style={{ padding: '12px 28px 0' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <button style={iconBtn} onClick={() => nav.back && nav.back()}>
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M12 4l-6 6 6 6" stroke={C.ink} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </button>
          <div style={{ fontFamily: FS.mono, fontSize: 10, letterSpacing: 1.2, color: C.muted, textTransform: 'uppercase' }}>Samia · Bibliothèque</div>
          <button style={iconBtn} aria-label="Recherche vocale">
            <svg width="18" height="18" viewBox="0 0 18 18" fill="none"><circle cx="8" cy="8" r="5.5" stroke={C.ink} strokeWidth="1.6"/><path d="M13 13l3 3" stroke={C.ink} strokeWidth="1.6" strokeLinecap="round"/></svg>
          </button>
        </div>

        <h2 style={{ marginTop: 28, marginBottom: 6, fontWeight: 400, fontSize: 32, letterSpacing: -1 }}>
          Que souhaitez-<br/>vous écouter&nbsp;?
        </h2>
        <p style={{ fontSize: 14, color: C.muted, margin: 0 }}>
          Touchez un livre, ou dites « Samia, lis-moi… »
        </p>

        <div style={{ marginTop: 24, display: 'flex', flexDirection: 'column', gap: 12 }}>
          {books.map((b, i) => (
            <div key={b.id} onClick={() => nav.go && nav.go('samiaPlay', { book: b })} style={{
              cursor: 'pointer', userSelect: 'none',
              background: C.card, borderRadius: 18, padding: 14,
              border: `1px solid ${C.hair}`,
              display: 'flex', gap: 14, alignItems: 'center',
            }}>
              <div style={{
                width: 56, height: 72, borderRadius: 6, overflow: 'hidden',
                background: b.color,
                position: 'relative', flexShrink: 0,
                display: 'flex', alignItems: 'flex-end', padding: 6, boxSizing: 'border-box',
              }}>
                <div style={{
                  fontFamily: FS.sans, fontSize: 7, fontWeight: 600,
                  color: 'rgba(255,255,255,0.85)', lineHeight: 1.1, letterSpacing: 0.2,
                }}>{b.t.toUpperCase()}</div>
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 16, fontWeight: 500, letterSpacing: -0.2 }}>{b.t}</div>
                <div style={{ fontSize: 13, color: C.muted, marginTop: 2 }}>{b.a}</div>
                <div style={{ display: 'flex', gap: 8, marginTop: 6, alignItems: 'center' }}>
                  <span style={{
                    fontFamily: FS.mono, fontSize: 10, color: C.muted,
                    background: C.pill, padding: '2px 6px', borderRadius: 4,
                  }}>{b.d}</span>
                  <span style={{ fontFamily: FS.mono, fontSize: 10, color: C.faint }}>· {b.cat}</span>
                </div>
              </div>
              <button style={{
                width: 38, height: 38, borderRadius: 99, border: 'none', cursor: 'pointer',
                background: i === 0 ? C.accent : C.ink, color: '#fff',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }} onClick={(e) => { e.stopPropagation(); nav.go && nav.go('samiaPlay', { book: b }); }}>
                <svg width="11" height="13" viewBox="0 0 11 13"><path d="M0 0v13l11-6.5L0 0z" fill="#F6F2EB"/></svg>
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* Samia floating mic */}
      <div onClick={() => nav.go && nav.go('samiaPlay', { book: books[0] })} style={{
        cursor: 'pointer', userSelect: 'none',
        position: 'absolute', bottom: 28, left: '50%', transform: 'translateX(-50%)',
        background: C.ink, color: '#F6F2EB',
        padding: '12px 18px 12px 14px', borderRadius: 99,
        display: 'flex', alignItems: 'center', gap: 10,
        boxShadow: '0 8px 24px rgba(27,26,23,0.25)',
      }}>
        <div style={{
          width: 28, height: 28, borderRadius: 99, background: C.accent,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <svg width="11" height="14" viewBox="0 0 11 14" fill="none">
            <rect x="3" y="0" width="5" height="9" rx="2.5" fill="#fff"/>
            <path d="M1 7v1a4.5 4.5 0 009 0V7M5.5 12.5V14" stroke="#fff" strokeWidth="1.3" strokeLinecap="round"/>
          </svg>
        </div>
        <span style={{ fontSize: 14, fontWeight: 500 }}>Parler à Samia</span>
        <span style={{ fontFamily: FS.ar, fontSize: 14, color: 'rgba(246,242,235,0.7)' }}>سامية</span>
      </div>
    </Phone>
  );
}

const iconBtn = {
  width: 36, height: 36, borderRadius: 12,
  background: 'transparent', border: 'none', cursor: 'pointer',
  display: 'flex', alignItems: 'center', justifyContent: 'center',
};

// ═══ SCREEN 3 — Samia en écoute / lecture ══════════════════════
function S3_SamiaListening({ nav = {} }) {
  const book = (nav.params && nav.params.book) || {
    t: 'Le Pain Nu', a: 'Mohamed Choukri', chapter: 'Chapitre trois',
  };
  return (
    <Phone dark>
      <div style={{ padding: '12px 28px 0', height: '100%', display: 'flex', flexDirection: 'column', color: '#F6F2EB' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <button style={{ ...iconBtn, color: '#F6F2EB' }} onClick={() => nav.back && nav.back()}>
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M12 4l-6 6 6 6" stroke="#F6F2EB" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </button>
          <div style={{ fontFamily: FS.mono, fontSize: 10, letterSpacing: 1.4, color: 'rgba(246,242,235,0.5)', textTransform: 'uppercase', maxWidth: 180, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            En cours · {book.t}
          </div>
          <div style={{
            fontFamily: FS.mono, fontSize: 10, color: 'rgba(246,242,235,0.5)',
            display: 'flex', alignItems: 'center', gap: 6,
          }}>
            <span style={{ width: 6, height: 6, borderRadius: 99, background: C.accent, display: 'inline-block' }} />
            écoute
          </div>
        </div>

        <div style={{ marginTop: 50, flex: 1 }}>
          {/* big waveform */}
          <div style={{
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            gap: 5, height: 120, marginBottom: 40,
          }}>
            {Array.from({ length: 28 }).map((_, i) => {
              const heights = [12,18,26,38,52,68,80,94,72,58,46,32,20,28,42,60,76,88,96,82,66,48,30,22,16,24,32,18];
              return (
                <div key={i} style={{
                  width: 3, height: heights[i], borderRadius: 2,
                  background: i < 18 ? C.accent : 'rgba(246,242,235,0.25)',
                }} />
              );
            })}
          </div>

          <div style={{ fontFamily: FS.mono, fontSize: 11, color: 'rgba(246,242,235,0.4)', textTransform: 'uppercase', letterSpacing: 1.4 }}>
            Vous avez dit
          </div>
          <div style={{
            fontFamily: FS.sans, fontWeight: 400, fontSize: 26, lineHeight: 1.25,
            letterSpacing: -0.8, marginTop: 10, textWrap: 'balance',
          }}>
            «&nbsp;Samia, lis-moi<br/>
            <span style={{ color: C.accent }}>{(book.chapter || 'le chapitre un').toLowerCase()}</span>&nbsp;de<br/>
            <em style={{ fontStyle: 'normal', color: 'rgba(246,242,235,0.85)' }}>{book.t}</em>.&nbsp;»
          </div>

          <div style={{
            marginTop: 24, padding: '14px 16px',
            background: 'rgba(246,242,235,0.06)', borderRadius: 14,
            border: '1px solid rgba(246,242,235,0.08)',
          }}>
            <div style={{ fontFamily: FS.mono, fontSize: 10, color: 'rgba(246,242,235,0.45)', letterSpacing: 1, textTransform: 'uppercase' }}>
              Samia →
            </div>
            <div style={{ marginTop: 6, fontSize: 15, lineHeight: 1.5, color: 'rgba(246,242,235,0.92)' }}>
              D'accord. Je commence {(book.chapter || 'le chapitre un').toLowerCase()} de <em style={{ fontStyle: 'normal', color: '#F6F2EB' }}>{book.t}</em>, en darija. Dites «&nbsp;pause&nbsp;» à tout moment.
            </div>
          </div>
        </div>

        {/* controls */}
        <div style={{
          paddingBottom: 36, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        }}>
          <DarkCtrl><svg width="22" height="22" viewBox="0 0 22 22" fill="none"><path d="M14 4v14M12 11L4 4v14l8-7z" stroke="#F6F2EB" strokeWidth="1.6" strokeLinejoin="round"/></svg></DarkCtrl>
          <DarkCtrl><span style={{ fontFamily: FS.mono, fontSize: 12, color: '#F6F2EB' }}>−15s</span></DarkCtrl>
          <div style={{
            width: 76, height: 76, borderRadius: 99, background: C.accent,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 0 0 8px rgba(184,85,45,0.18), 0 0 0 16px rgba(184,85,45,0.08)',
          }}>
            <svg width="22" height="22" viewBox="0 0 22 22"><rect x="5" y="3" width="5" height="16" rx="1.5" fill="#fff"/><rect x="12" y="3" width="5" height="16" rx="1.5" fill="#fff"/></svg>
          </div>
          <DarkCtrl><span style={{ fontFamily: FS.mono, fontSize: 12, color: '#F6F2EB' }}>+15s</span></DarkCtrl>
          <DarkCtrl><svg width="22" height="22" viewBox="0 0 22 22" fill="none"><path d="M8 4v14M10 11l8-7v14l-8-7z" stroke="#F6F2EB" strokeWidth="1.6" strokeLinejoin="round"/></svg></DarkCtrl>
        </div>
      </div>
    </Phone>
  );
}

function DarkCtrl({ children }) {
  return (
    <div style={{
      width: 48, height: 48, borderRadius: 99,
      background: 'rgba(246,242,235,0.06)',
      border: '1px solid rgba(246,242,235,0.1)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>{children}</div>
  );
}

// ═══ SCREEN 4 — SignBook home (avatar icons) ═══════════════════
function S4_SignHome({ nav = {} }) {
  const tiles = [
    { t: "Bibliothèque", s: "كتب",            label: "avatar · bibliothèque" },
    { t: "Mes lectures", s: "قراءاتي",         label: "avatar · favoris" },
    { t: "Apprendre",    s: "تعلم",            label: "avatar · alphabet LSM" },
    { t: "Réglages",     s: "إعدادات",         label: "avatar · réglages" },
  ];
  return (
    <Phone>
      <div style={{ padding: '12px 24px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <button style={iconBtn} onClick={() => nav.back && nav.back()}>
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M12 4l-6 6 6 6" stroke={C.ink} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </button>
          <div style={{ fontFamily: FS.mono, fontSize: 10, letterSpacing: 1.2, color: C.muted, textTransform: 'uppercase' }}>SignBook</div>
          <div style={{ width: 36 }} />
        </div>

        <div style={{ padding: '20px 4px 8px' }}>
          <h2 style={{ margin: 0, fontWeight: 400, fontSize: 30, letterSpacing: -0.9, lineHeight: 1.15 }}>
            Bonjour Yasmine.
          </h2>
          <p style={{ margin: '6px 0 0', fontSize: 14, color: C.muted }}>
            Appuyez longuement sur une icône — un avatar l'explique en LSM.
          </p>
        </div>

        <div style={{
          display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14, marginTop: 20,
        }}>
          {tiles.map((t, i) => (
            <div key={i} onClick={() => i === 0 && nav.go && nav.go('signLib')} style={{
              cursor: i === 0 ? 'pointer' : 'default', userSelect: 'none',
              background: C.card, borderRadius: 22, padding: 14, paddingBottom: 16,
              border: `1px solid ${C.hair}`,
              position: 'relative', overflow: 'hidden',
            }}>
              <div style={{
                height: 110, borderRadius: 14, overflow: 'hidden', marginBottom: 12,
                background: i % 2 === 0 ? '#F1ECE2' : '#EDE6D8',
              }}>
                <SigningAvatar
                  variant={['open','heart','spell','point'][i]}
                  palette={i % 2 === 0 ? 'cream' : 'warm'}
                  delay={`${i * 0.3}s`}
                />
              </div>
              <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
                <div style={{ fontSize: 16, fontWeight: 500, letterSpacing: -0.2 }}>{t.t}</div>
                <div style={{ fontFamily: FS.ar, fontSize: 12, color: C.muted, direction: 'rtl' }}>{t.s}</div>
              </div>
              {/* LSM dot indicator */}
              <div style={{
                position: 'absolute', top: 22, right: 22,
                background: 'rgba(27,26,23,0.85)', color: '#F6F2EB',
                fontFamily: FS.mono, fontSize: 9, letterSpacing: 0.8,
                padding: '3px 7px', borderRadius: 99,
              }}>LSM</div>
            </div>
          ))}
        </div>

        {/* daily sign card */}
        <div style={{
          marginTop: 16, background: C.ink, color: '#F6F2EB',
          borderRadius: 22, padding: '16px 18px',
          display: 'flex', alignItems: 'center', gap: 14,
        }}>
          <div style={{
            width: 54, height: 54, borderRadius: 14, overflow: 'hidden',
            background: '#2a2520',
          }}>
            <SigningAvatar variant="read" palette="dark" glow={false} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: FS.mono, fontSize: 10, color: 'rgba(246,242,235,0.5)', letterSpacing: 1, textTransform: 'uppercase' }}>Signe du jour</div>
            <div style={{ fontSize: 17, fontWeight: 500, marginTop: 2, letterSpacing: -0.2 }}>« Lire »</div>
          </div>
          <svg width="20" height="14" viewBox="0 0 22 14" fill="none">
            <path d="M1 7h19m0 0l-6-6m6 6l-6 6" stroke="#F6F2EB" strokeWidth="1.4" strokeLinecap="round"/>
          </svg>
        </div>
      </div>
    </Phone>
  );
}

// ═══ SCREEN 5 — Bibliothèque LSM ═══════════════════════════════
function S5_SignLibrary({ nav = {} }) {
  const books = [
    {
      id: 'prince',
      t: "Le Petit Prince",   a: "Antoine de Saint-Exupéry",
      tag: "Jeunesse",  dur: "12 chap.", variant: 'wave', palette: 'cream',
      chapter: "Chapitre 1 · paragraphe 3",
      excerpt: {
        pre: "Lorsque j'avais six ans j'ai vu, une fois, ",
        hi:  "une magnifique image",
        post:", dans un livre sur la forêt vierge…",
      },
    },
    {
      id: 'hayy',
      t: "Hayy Ibn Yaqdhan",  a: "Ibn Tufayl",
      tag: "Classique", dur: "8 chap.", variant: 'think', palette: 'warm',
      chapter: "Prologue · paragraphe 1",
      excerpt: {
        pre: "Nos pieux ancêtres — que Dieu leur accorde Sa miséricorde — racontent qu'il existe, parmi les îles de l'Inde, ",
        hi:  "une île déserte",
        post:" placée sous l'équateur…",
      },
    },
    {
      id: 'souffles',
      t: "Souffles",          a: "Abdellatif Laâbi",
      tag: "Poésie",    dur: "24 poèmes", variant: 'poem', palette: 'cool',
      chapter: "Poème · « Race »",
      excerpt: {
        pre: "Je suis né d'une terre qui ne connaît pas ses frontières, ",
        hi:  "fils du vent",
        post:" et de l'orange amère…",
      },
    },
  ];
  return (
    <Phone>
      <div style={{ padding: '12px 24px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <button style={iconBtn} onClick={() => nav.back && nav.back()}>
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M12 4l-6 6 6 6" stroke={C.ink} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </button>
          <div style={{ fontFamily: FS.mono, fontSize: 10, letterSpacing: 1.2, color: C.muted, textTransform: 'uppercase' }}>Bibliothèque · LSM</div>
          <div style={{ width: 36 }} />
        </div>

        <h2 style={{ marginTop: 22, marginBottom: 4, fontWeight: 400, fontSize: 28, letterSpacing: -0.9, lineHeight: 1.15 }}>
          Choisissez un livre.<br/>
          <span style={{ color: C.muted }}>L'avatar le racontera.</span>
        </h2>

        {/* filter chips */}
        <div style={{ display: 'flex', gap: 8, marginTop: 18, flexWrap: 'wrap' }}>
          {['Tous', 'Jeunesse', 'Classique', 'Poésie', 'Récits'].map((c, i) => (
            <div key={c} style={{
              padding: '7px 12px', borderRadius: 99,
              background: i === 0 ? C.ink : 'transparent',
              color: i === 0 ? '#F6F2EB' : C.ink2,
              border: i === 0 ? 'none' : `1px solid ${C.hair}`,
              fontSize: 12, fontWeight: 500, letterSpacing: -0.1,
            }}>{c}</div>
          ))}
        </div>

        {/* books with GIF previews */}
        <div style={{ marginTop: 20, display: 'flex', flexDirection: 'column', gap: 14 }}>
          {books.map((b, i) => (
            <div key={b.id} onClick={() => nav.go && nav.go('signRead', { book: b })} style={{
              cursor: 'pointer', userSelect: 'none',
              background: C.card, borderRadius: 20, padding: 14,
              border: `1px solid ${C.hair}`,
              display: 'flex', gap: 14, alignItems: 'stretch',
            }}>
              <div style={{
                width: 92, height: 116, borderRadius: 8, overflow: 'hidden',
                background: '#E8E1D5', position: 'relative', flexShrink: 0,
                boxShadow: '0 4px 12px rgba(40,30,20,0.18), 0 0 0 1px rgba(0,0,0,0.06)',
              }}>
                <BookCover book={b} />
                {/* play dot — overlay on cover */}
                <div style={{
                  position: 'absolute', bottom: 6, right: 6,
                  width: 24, height: 24, borderRadius: 99,
                  background: 'rgba(27,26,23,0.88)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  backdropFilter: 'blur(4px)',
                }}>
                  <svg width="8" height="10" viewBox="0 0 7 9"><path d="M0 0v9l7-4.5L0 0z" fill="#F6F2EB"/></svg>
                </div>
              </div>
              <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column' }}>
                <div style={{ fontSize: 16, fontWeight: 500, letterSpacing: -0.2, lineHeight: 1.2 }}>{b.t}</div>
                <div style={{ fontSize: 13, color: C.muted, marginTop: 2 }}>{b.a}</div>
                <div style={{ flex: 1 }} />
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 8 }}>
                  <span style={{
                    fontFamily: FS.mono, fontSize: 10, color: C.muted,
                    background: C.pill, padding: '3px 7px', borderRadius: 4,
                  }}>{b.tag}</span>
                  <span style={{ fontFamily: FS.mono, fontSize: 10, color: C.faint }}>· {b.dur}</span>
                </div>
                <button style={{
                  marginTop: 10, alignSelf: 'flex-start',
                  background: C.ink, color: '#F6F2EB',
                  border: 'none', padding: '7px 14px', borderRadius: 99,
                  fontSize: 12, fontWeight: 500, fontFamily: FS.sans, cursor: 'pointer',
                }}>Lire en LSM →</button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </Phone>
  );
}

// ═══ SCREEN 6 — Lecture en LSM (avatar 3D signant) ═════════════
function S6_SignReader({ nav = {} }) {
  const book = (nav.params && nav.params.book) || {
    t: 'Le Petit Prince', a: 'Antoine de Saint-Exupéry',
    variant: 'wave', palette: 'cream', chapter: 'Chapitre 1 · paragraphe 3',
    excerpt: {
      pre: "Lorsque j'avais six ans j'ai vu, une fois, ",
      hi: "une magnifique image",
      post: ", dans un livre sur la forêt vierge…",
    },
  };
  return (
    <Phone>
      <div style={{ padding: '12px 24px 0', height: '100%', display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <button style={iconBtn} onClick={() => nav.back && nav.back()}>
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none"><path d="M12 4l-6 6 6 6" stroke={C.ink} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </button>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{
              width: 26, height: 34, borderRadius: 3, overflow: 'hidden',
              boxShadow: '0 2px 6px rgba(40,30,20,0.2), 0 0 0 0.5px rgba(0,0,0,0.1)',
              flexShrink: 0,
            }}>
              <BookCover book={book} size="sm" />
            </div>
            <div style={{ textAlign: 'left' }}>
              <div style={{ fontFamily: FS.mono, fontSize: 9, letterSpacing: 1.2, color: C.muted, textTransform: 'uppercase' }}>En lecture</div>
              <div style={{
                fontSize: 13, fontWeight: 500, marginTop: 1,
                maxWidth: 150, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
              }}>{book.t}</div>
            </div>
          </div>
          <button style={iconBtn}>
            <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
              <circle cx="4" cy="9" r="1.5" fill={C.ink}/>
              <circle cx="9" cy="9" r="1.5" fill={C.ink}/>
              <circle cx="14" cy="9" r="1.5" fill={C.ink}/>
            </svg>
          </button>
        </div>

        {/* 3D avatar stage */}
        <div style={{
          marginTop: 18, borderRadius: 22, overflow: 'hidden',
          background: 'linear-gradient(180deg, #ECE5D6 0%, #DACDB1 100%)',
          height: 340, position: 'relative',
        }}>
          <SigningAvatar variant={book.variant || 'open'} palette={book.palette || 'cream'} />
          {/* corner labels */}
          <div style={{
            position: 'absolute', top: 14, left: 14,
            background: 'rgba(27,26,23,0.78)', color: '#F6F2EB',
            fontFamily: FS.mono, fontSize: 9, letterSpacing: 0.8,
            padding: '4px 8px', borderRadius: 99,
            display: 'flex', alignItems: 'center', gap: 6,
          }}>
            <span style={{ width: 5, height: 5, borderRadius: 99, background: C.accent }}/> AVATAR 3D · LSM
          </div>
          <div style={{
            position: 'absolute', top: 14, right: 14,
            background: 'rgba(246,242,235,0.85)', color: C.ink,
            fontFamily: FS.mono, fontSize: 9, letterSpacing: 0.6,
            padding: '4px 8px', borderRadius: 99,
          }}>0.8×</div>
        </div>

        {/* current paragraph */}
        <div style={{ marginTop: 18, flex: 1 }}>
          <div style={{ fontFamily: FS.mono, fontSize: 10, color: C.muted, letterSpacing: 1.2, textTransform: 'uppercase' }}>
            {book.chapter || 'Chapitre 1'}
          </div>
          <p style={{
            margin: '8px 0 0', fontSize: 16, lineHeight: 1.55, color: C.ink2, textWrap: 'pretty',
          }}>
            <span style={{ color: C.faint }}>{book.excerpt && book.excerpt.pre}</span>
            <span style={{ background: C.accentSoft, padding: '2px 4px', borderRadius: 4, color: C.ink }}>
              {book.excerpt && book.excerpt.hi}
            </span>
            <span style={{ color: C.faint }}>{book.excerpt && book.excerpt.post}</span>
          </p>
        </div>

        {/* progress + controls */}
        <div style={{ paddingBottom: 28 }}>
          <div style={{ height: 3, background: C.hair, borderRadius: 99, overflow: 'hidden', marginBottom: 14 }}>
            <div style={{ width: '34%', height: '100%', background: C.accent }} />
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontFamily: FS.mono, fontSize: 11, color: C.muted }}>04:12</span>
            <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
              <button style={ctrlLight}><svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M9 2L4 7l5 5" stroke={C.ink} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg></button>
              <button style={{
                width: 52, height: 52, borderRadius: 99, background: C.ink, border: 'none',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <svg width="14" height="14" viewBox="0 0 14 14"><rect x="2" y="1" width="3.5" height="12" rx="1" fill="#F6F2EB"/><rect x="8.5" y="1" width="3.5" height="12" rx="1" fill="#F6F2EB"/></svg>
              </button>
              <button style={ctrlLight}><svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M5 2l5 5-5 5" stroke={C.ink} strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round"/></svg></button>
            </div>
            <span style={{ fontFamily: FS.mono, fontSize: 11, color: C.muted }}>12:48</span>
          </div>
        </div>
      </div>
    </Phone>
  );
}

const ctrlLight = {
  width: 36, height: 36, borderRadius: 99,
  background: 'transparent', border: `1px solid ${C.hair}`,
  display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
};

// ─── EXPORTS ───────────────────────────────────────────────────
Object.assign(window, {
  S1_Home, S2_AudioLibrary, S3_SamiaListening,
  S4_SignHome, S5_SignLibrary, S6_SignReader,
});
