import { defineConfig } from "vite";

export default defineConfig({
  root: '.',
  server: {
    open: 'index.html',
    port: 5173
  },
  build: {
    outDir: 'dist',
    rollupOptions: {
      input: {
        en: 'en/index.html',
        zh: 'zh/index.html'
      }
    }
  }
});
