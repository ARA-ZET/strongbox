/**
 * Renders a structured-data block.
 *
 * Schema graphs are built as plain objects in `lib/seo.ts` and serialised
 * here, so the shapes stay unit-testable and no page hand-writes JSON. The
 * `<` escape stops a string inside the data (an FAQ answer, an article
 * excerpt) from being able to close the script tag early.
 */
export default function JsonLd({ data }: { data: object | object[] }) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{
        __html: JSON.stringify(data).replace(/</g, "\\u003c"),
      }}
    />
  );
}
