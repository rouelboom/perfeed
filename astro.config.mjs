import { defineConfig } from 'astro/config';

export default defineConfig({
  // Единственное место с доменом: при переезде меняется только это значение.
  site: 'https://perf-kaluga.site',
  output: 'static',
  // Старый адрес списка событий: на него ссылаются архивные страницы perfeed.
  redirects: {
    '/events': '/archive/',
  },
  server: {
    port: 18081,
  },
});
