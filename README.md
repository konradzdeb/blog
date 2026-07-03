# thefinalartefact.xyz

Hugo site for <https://www.thefinalartefact.xyz>, built on PaperMod, with content focused on practical software, data, and tooling: R and Python workflows, data science/BI, Shiny apps, data pipelines, Docker and Git usage, editor and CLI setup, and occasional reviews or experiments.

## Local development

Use the project-local Hugo binary so local validation matches Netlify:

```sh
npm install
npm run server
```

Build locally with:

```sh
npm run build
```

The pinned Hugo version is `0.161.1`, matching `HUGO_VERSION` in `netlify.toml`.
