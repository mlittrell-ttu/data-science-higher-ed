# Applied Data Science for Higher Education with R

An open textbook, written in [Quarto](https://quarto.org/) as a book project.

## Prerequisites

- [R](https://cran.r-project.org/)
- RStudio or Positron
- [Quarto](https://quarto.org/) (bundled with recent RStudio)
- The packages your chapters use: `install.packages(c("tidyverse", "tidymodels"))`

## Open it

Double-click **`adshe-book.Rproj`** to open the project in RStudio. Edit the
`.qmd` files — start with `index.qmd` (the preface) and
`01-what-is-data-science.qmd` (a worked example of every formatting pattern).
The table of contents lives in `_quarto.yml`; add, remove, or reorder chapters
there.

## Preview while you write

```bash
quarto preview
```

Opens a live-reloading version in your browser that updates as you save.

## Build the whole book

```bash
quarto render
```

Output goes to `_book/`. With `freeze: auto` (set in `_quarto.yml`), each
chapter only re-runs its R code when that chapter changes; the cached results
live in `_freeze/`. **Commit `_freeze/`** so the optional GitHub Action can
publish without needing R.

## Publish free on GitHub Pages

1. Put this folder in a GitHub repo. Edit `site-url` and `repo-url` in
   `_quarto.yml` to match (`https://USERNAME.github.io/REPO/`).
2. From the project folder, run:

   ```bash
   quarto publish gh-pages
   ```

   This renders the book and pushes it to a `gh-pages` branch. The first time,
   it creates that branch and turns on Pages for you.
3. Your book is live at `https://USERNAME.github.io/REPO/`.

(There's also an optional GitHub Action in `.github/workflows/publish.yml` that
re-publishes on every push. It relies on a committed `_freeze/` folder.)

## Use your own domain

1. Buy a domain from any registrar (~$10–15/yr).
2. Add DNS records at the registrar pointing at GitHub Pages:
   - **Apex** (`yourbook.com`): four `A` records to GitHub's IPs
     (`185.199.108–111.153`).
   - **Subdomain** (`book.yourdomain.com`): one `CNAME` record to
     `USERNAME.github.io`.
3. Put your bare domain in the **`CNAME`** file in this folder (replace the
   placeholder), then uncomment the `resources: [CNAME]` lines in `_quarto.yml`
   so it survives every re-publish.
4. GitHub provisions free HTTPS automatically.

The domain is the one piece you own and pay for — if you ever move off GitHub
Pages, re-point the DNS and every link and citation still works.

## License

Released under **Creative Commons Attribution 4.0 (CC BY 4.0)** — see
`LICENSE.md`. Readers may share and adapt with attribution. Change this if you
want different terms.
