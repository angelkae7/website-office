/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "../templates/**/*.html.twig",
    "../../modules/**/*.html.twig",
    "../../themes/**/*.html.twig",
    "./assets/**/*.{js,css}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
