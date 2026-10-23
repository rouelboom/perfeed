import { defineConfig } from 'astro/config';

export default defineConfig({
  // Единственное место с доменом: при переезде меняется только это значение.
  site: 'https://perf-kaluga.site',
  output: 'static',
  server: {
    port: 18081,
  },
});
