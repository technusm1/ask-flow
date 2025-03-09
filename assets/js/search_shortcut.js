// Initialize search shortcut handling
let Hooks = {}

Hooks.SearchShortcut = {
  mounted() {
    // Prevent the default browser search
    window.addEventListener('keydown', (e) => {
      if (e.key === 'f' && e.metaKey && e.shiftKey) {
        e.preventDefault()
        // Focus on Search Input box
        const searchInput = document.querySelector('input[name="q"]')
        if (searchInput) {
          searchInput.focus()
          searchInput.select() // Select any existing text
        }
      }
    })

    // Handle form submission
    this.el.addEventListener('submit', (e) => {
      e.preventDefault()
      const query = this.el.querySelector('input[name="q"]').value
      if (query.trim()) {
        window.location.href = `/search?q=${encodeURIComponent(query)}`
      }
    })
  }
}

export default Hooks 