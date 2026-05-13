document.addEventListener('DOMContentLoaded', () => {
  const header = document.getElementById('header');
  const menuToggle = document.getElementById('menuToggle');
  const mobileNav = document.getElementById('mobileNav');
  const overlay = document.getElementById('overlay');
  const yearEl = document.getElementById('year');
  if (yearEl) yearEl.textContent = new Date().getFullYear();

  // Mobile nav
  const openNav = () => {
    menuToggle.classList.add('active');
    mobileNav.classList.add('active');
    overlay.classList.add('active');
    menuToggle.setAttribute('aria-expanded', 'true');
    document.body.style.overflow = 'hidden';
  };
  const closeNav = () => {
    menuToggle.classList.remove('active');
    mobileNav.classList.remove('active');
    overlay.classList.remove('active');
    menuToggle.setAttribute('aria-expanded', 'false');
    document.body.style.overflow = '';
  };
  menuToggle.addEventListener('click', () => {
    mobileNav.classList.contains('active') ? closeNav() : openNav();
  });
  overlay.addEventListener('click', closeNav);
  mobileNav.querySelectorAll('a').forEach(a => a.addEventListener('click', closeNav));
  document.addEventListener('keydown', e => {
    if (e.key === 'Escape' && mobileNav.classList.contains('active')) closeNav();
  });

  // Header scroll
  let ticking = false;
  const handleScroll = () => {
    header.classList.toggle('scrolled', window.scrollY > 40);
    ticking = false;
  };
  window.addEventListener('scroll', () => {
    if (!ticking) { requestAnimationFrame(handleScroll); ticking = true; }
  }, { passive: true });

  // IntersectionObserver for .animate-on-scroll
  if ('IntersectionObserver' in window) {
    const io = new IntersectionObserver(entries => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          e.target.classList.add('visible');
          io.unobserve(e.target);
        }
      });
    }, { threshold: 0.12 });
    document.querySelectorAll('.animate-on-scroll').forEach(el => io.observe(el));
  } else {
    document.querySelectorAll('.animate-on-scroll').forEach(el => el.classList.add('visible'));
  }

  // Menu tabs (Breakfast / Lunch)
  const tabs = Array.from(document.querySelectorAll('.menu-tab'));
  const panels = Array.from(document.querySelectorAll('.menu-panel'));
  const activateTab = (key, { focus = false } = {}) => {
    tabs.forEach(t => {
      const isActive = t.dataset.menu === key;
      t.classList.toggle('active', isActive);
      t.setAttribute('aria-selected', isActive);
      t.tabIndex = isActive ? 0 : -1;
      if (isActive && focus) t.focus();
    });
    panels.forEach(p => {
      const isActive = p.dataset.menu === key;
      p.classList.toggle('active', isActive);
      if (isActive) p.removeAttribute('hidden'); else p.setAttribute('hidden', '');
    });
    if (history.replaceState) {
      const target = key === 'lunch' ? '#menu-lunch' : '#menu';
      history.replaceState(null, '', target);
    }
  };
  tabs.forEach(t => t.addEventListener('click', () => activateTab(t.dataset.menu)));
  tabs.forEach((t, i) => t.addEventListener('keydown', e => {
    if (e.key === 'ArrowRight' || e.key === 'ArrowLeft') {
      e.preventDefault();
      const dir = e.key === 'ArrowRight' ? 1 : -1;
      const next = tabs[(i + dir + tabs.length) % tabs.length];
      activateTab(next.dataset.menu, { focus: true });
    }
  }));
  // Deep-link support
  if (location.hash === '#menu-lunch') activateTab('lunch');

  // Lightbox
  const lightbox = document.getElementById('lightbox');
  const lightboxImg = document.getElementById('lightboxImg');
  const lightboxCaption = document.getElementById('lightboxCaption');
  const triggers = Array.from(document.querySelectorAll('.lightbox-trigger img'));
  if (lightbox && triggers.length) {
    let current = 0;
    const show = (i) => {
      current = (i + triggers.length) % triggers.length;
      const img = triggers[current];
      lightboxImg.src = img.src;
      lightboxImg.alt = img.alt || '';
      lightboxCaption.textContent = img.alt || '';
    };
    const open = (i) => {
      show(i);
      lightbox.classList.add('active');
      lightbox.setAttribute('aria-hidden', 'false');
      document.body.classList.add('lightbox-open');
    };
    const close = () => {
      lightbox.classList.remove('active');
      lightbox.setAttribute('aria-hidden', 'true');
      document.body.classList.remove('lightbox-open');
      lightboxImg.src = '';
    };
    triggers.forEach((img, i) => {
      img.parentElement.addEventListener('click', () => open(i));
      img.parentElement.setAttribute('tabindex', '0');
      img.parentElement.setAttribute('role', 'button');
      img.parentElement.setAttribute('aria-label', 'View ' + (img.alt || 'photo') + ' larger');
      img.parentElement.addEventListener('keydown', e => {
        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); open(i); }
      });
    });
    document.getElementById('lightboxClose').addEventListener('click', close);
    document.getElementById('lightboxPrev').addEventListener('click', () => show(current - 1));
    document.getElementById('lightboxNext').addEventListener('click', () => show(current + 1));
    lightbox.addEventListener('click', e => { if (e.target === lightbox) close(); });
    document.addEventListener('keydown', e => {
      if (!lightbox.classList.contains('active')) return;
      if (e.key === 'Escape') close();
      else if (e.key === 'ArrowLeft') show(current - 1);
      else if (e.key === 'ArrowRight') show(current + 1);
    });
  }
});
