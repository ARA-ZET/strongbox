import type { Metadata } from "next";
import { notFound } from "next/navigation";
import ArticleLayout from "@/components/ArticleLayout";
import JsonLd from "@/components/JsonLd";
import { ARTICLES, getArticle } from "@/lib/resources";
import { pageMeta, articleJsonLd, breadcrumbJsonLd } from "@/lib/seo";

/** Next 15 hands route params in as a promise. */
type Params = { params: Promise<{ slug: string }> };

export function generateStaticParams() {
  return ARTICLES.map(({ slug }) => ({ slug }));
}

export async function generateMetadata({ params }: Params): Promise<Metadata> {
  const { slug } = await params;
  const article = getArticle(slug);
  // A miss renders the 404, which must not be indexed under the requested URL.
  if (!article) return { title: "Guide not found", robots: { index: false, follow: true } };

  return pageMeta({
    title: article.title,
    description: article.excerpt,
    path: `/resources/${article.slug}`,
    type: "article",
    modifiedTime: article.updated,
  });
}

export default async function ArticlePage({ params }: Params) {
  const { slug } = await params;
  const article = getArticle(slug);
  if (!article) notFound();

  return (
    <>
      <JsonLd
        data={[
          articleJsonLd(article),
          breadcrumbJsonLd([
            { name: "Guides", path: "/resources" },
            { name: article.title, path: `/resources/${article.slug}` },
          ]),
        ]}
      />
      <ArticleLayout article={article} />
    </>
  );
}
