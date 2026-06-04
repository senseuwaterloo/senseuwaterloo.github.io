document.addEventListener('DOMContentLoaded', () => {
  const nav = document.querySelector('nav');
  const navToggle = document.querySelector('.nav-toggle');
  const navLinks = document.querySelector('.nav-links');
  const links = document.querySelectorAll('.nav-links a');
  const toggleAllBtn = document.getElementById('toggle-all-pubs');

  // --- Mobile hamburger menu toggle ---
  navToggle?.addEventListener('click', () => {
    const isOpen = navLinks?.classList.toggle('nav-open');
    navToggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
  });

  // Close menu when a nav link is clicked
  links.forEach(link => {
    link.addEventListener('click', () => {
      navLinks?.classList.remove('nav-open');
    });
  });

  // --- Active navigation highlighting based on current URL ---
  const currentPath = window.location.pathname.split('/').pop() || 'index.html';
  links.forEach(link => {
    const href = link.getAttribute('href');
    if (href === currentPath || (currentPath === '' && href === 'index.html')) {
      link.classList.add('active');
    } else {
      link.classList.remove('active');
    }
  });

  // --- Scroll-based nav shadow ---
  window.addEventListener('scroll', () => {
    nav?.classList.toggle('scrolled', window.scrollY > 50);
  }, { passive: true });

  // --- Publications Filtering & Search ---
  const pubSearch = document.getElementById('pub-search');
  const clearSearchBtn = document.getElementById('clear-search-btn');
  const filterTopic = document.getElementById('filter-topic');
  const filterType = document.getElementById('filter-type');
  const filterYear = document.getElementById('filter-year');
  const filterVenue = document.getElementById('filter-venue');
  const resetFiltersBtn = document.getElementById('reset-filters');
  const pubCounts = document.getElementById('pub-counts');
  const pubEntries = document.querySelectorAll('.pub-entry');

  if (pubSearch && filterTopic && filterType && filterYear && filterVenue) {
    // 1. Dynamic Dropdowns Population (Year & Venue)
    const years = new Set();
    const venues = new Set();

    pubEntries.forEach(entry => {
      const year = entry.getAttribute('data-year');
      const venue = entry.getAttribute('data-venue');
      if (year) years.add(year);
      if (venue) venues.add(venue);
    });

    // Populate Years (Sorted Descending)
    [...years].sort((a, b) => b - a).forEach(year => {
      const opt = document.createElement('option');
      opt.value = year;
      opt.textContent = year;
      filterYear.appendChild(opt);
    });

    // Populate Venues (Sorted Alphabetically, Other at the end)
    const sortedVenues = [...venues].sort((a, b) => {
      if (a === 'Other') return 1;
      if (b === 'Other') return -1;
      return a.localeCompare(b);
    });
    sortedVenues.forEach(venue => {
      const opt = document.createElement('option');
      opt.value = venue;
      opt.textContent = venue;
      filterVenue.appendChild(opt);
    });

    // 2. Filter Function
    function filterPublications() {
      const query = pubSearch.value.toLowerCase().trim();
      const topic = filterTopic.value;
      const type = filterType.value;
      const year = filterYear.value;
      const venue = filterVenue.value;

      let visibleCount = 0;

      pubEntries.forEach(entry => {
        const entryText = entry.textContent.toLowerCase();
        const entryTopic = entry.getAttribute('data-topic') || '';
        const entryType = entry.getAttribute('data-type') || '';
        const entryYear = entry.getAttribute('data-year') || '';
        const entryVenue = entry.getAttribute('data-venue') || '';

        // Match search query
        const matchesQuery = !query || entryText.includes(query);
        // Match topic (space separated keywords, e.g. "ai-llm performance")
        const matchesTopic = topic === 'all' || entryTopic.split(' ').includes(topic);
        // Match type
        const matchesType = type === 'all' || entryType === type;
        // Match year
        const matchesYear = year === 'all' || entryYear === year;
        // Match venue
        const matchesVenue = venue === 'all' || entryVenue === venue;

        if (matchesQuery && matchesTopic && matchesType && matchesYear && matchesVenue) {
          entry.classList.remove('hidden');
          visibleCount++;
        } else {
          entry.classList.add('hidden');
        }
      });

      // Show/Hide Groups & Years containers
      const groups = document.querySelectorAll('.pub-group');
      groups.forEach(group => {
        const visibleEntries = group.querySelectorAll('.pub-entry:not(.hidden)');
        if (visibleEntries.length === 0) {
          group.classList.add('hidden');
        } else {
          group.classList.remove('hidden');
        }
      });

      const yearsDetails = document.querySelectorAll('.pub-year');
      yearsDetails.forEach(details => {
        const visibleEntries = details.querySelectorAll('.pub-entry:not(.hidden)');
        if (visibleEntries.length === 0) {
          details.classList.add('hidden');
        } else {
          details.classList.remove('hidden');
          // Auto-open active matching years for better visibility
          if (query || topic !== 'all' || type !== 'all' || year !== 'all' || venue !== 'all') {
            details.open = true;
          }
        }
      });

      // Update count display
      const totalCount = pubEntries.length;
      pubCounts.textContent = `Showing ${visibleCount} of ${totalCount} publications`;

      // Clear search button visibility
      clearSearchBtn.style.display = query ? 'block' : 'none';

      // Reset filters button visibility
      const isFiltered = query || topic !== 'all' || type !== 'all' || year !== 'all' || venue !== 'all';
      resetFiltersBtn.style.display = isFiltered ? 'inline-block' : 'none';
    }

    // 3. Event Listeners
    pubSearch.addEventListener('input', filterPublications);
    filterTopic.addEventListener('change', filterPublications);
    filterType.addEventListener('change', filterPublications);
    filterYear.addEventListener('change', filterPublications);
    filterVenue.addEventListener('change', filterPublications);

    clearSearchBtn?.addEventListener('click', () => {
      pubSearch.value = '';
      filterPublications();
      pubSearch.focus();
    });

    resetFiltersBtn?.addEventListener('click', () => {
      pubSearch.value = '';
      filterTopic.value = 'all';
      filterType.value = 'all';
      filterYear.value = 'all';
      filterVenue.value = 'all';
      filterPublications();
    });
  }

  // --- Publication year toggle ---
  toggleAllBtn?.addEventListener('click', () => {
    // Only toggle visible years (i.e. not hidden by filter)
    const visibleDetails = document.querySelectorAll('.pub-year:not(.hidden)');
    const allOpen = [...visibleDetails].every(d => d.open);

    visibleDetails.forEach(d => (d.open = !allOpen));
    toggleAllBtn.textContent = allOpen ? 'Expand All' : 'Collapse All';
  });
});
