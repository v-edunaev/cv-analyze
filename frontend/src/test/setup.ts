import '@testing-library/jest-dom'

// Mock IntersectionObserver
if (!globalThis.IntersectionObserver) {
  globalThis.IntersectionObserver = class {
    observe() {}
    disconnect() {}
    unobserve() {}
  } as any
}

// Mock ResizeObserver
if (!globalThis.ResizeObserver) {
  globalThis.ResizeObserver = class {
    observe() {}
    disconnect() {}
    unobserve() {}
  } as any
}

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: (query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: () => {}, // deprecated
    removeListener: () => {}, // deprecated
    addEventListener: () => {},
    removeEventListener: () => {},
    dispatchEvent: () => false,
  }),
})

// Mock URL.createObjectURL
if (!globalThis.URL) {
  globalThis.URL = {
    createObjectURL: () => 'mock-url',
    revokeObjectURL: () => {},
  } as any
}