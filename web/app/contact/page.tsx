"use client";

import { useState } from "react";
import {
  CONTACT_PHONE_DISPLAY,
  CONTACT_PHONE_HREF,
  CONTACT_EMAIL,
  CONTACT_EMAIL_HREF,
  SOCIAL_LINKS,
  HQ_ADDRESS_LINES,
  HQ_MAPS_HREF,
  HQ_SUBURB,
  OPENING_HOURS_LINES,
  SERVICE_AREAS,
} from "@/lib/constants";
import SocialIcon from "@/components/graphics/SocialIcon";
import Illustration from "@/components/graphics/Illustration";

export default function ContactPage() {
  const [sent, setSent] = useState(false);

  /*
   * No form backend exists yet. Flashing "Message Sent!" while dropping the
   * message on the floor is the worst possible outcome here — a prospect
   * believes they have reached us and never hears back. Until an endpoint is
   * wired up, the form composes the enquiry into the visitor's own mail
   * client, so the message genuinely arrives. Replace the body of this
   * function with a POST when Formspree / Resend / a Cloud Function is ready;
   * nothing else on the page has to change.
   */
  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const data = new FormData(e.currentTarget);
    const get = (k: string) => String(data.get(k) ?? "").trim();

    const subject = `${get("subject")} — website enquiry from ${get("name")}`;
    const body = [
      `Name: ${get("name")}`,
      `Email: ${get("email")}`,
      `Phone: ${get("phone") || "not given"}`,
      "",
      get("message"),
    ].join("\n");

    window.location.href = `${CONTACT_EMAIL_HREF}?subject=${encodeURIComponent(
      subject
    )}&body=${encodeURIComponent(body)}`;
    setSent(true);
  };

  return (
    <>
      {/* Hero */}
      <section className="py-16 md:py-20 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop grid md:grid-cols-2 gap-10 items-center">
          <div>
            <h1 className="text-headline-h1 font-bold text-navy-deep mb-4">Get in Touch</h1>
            <p className="text-on-surface-variant text-body-main max-w-xl">
              Experience the gold standard of valet storage. Our concierge team typically responds within 2 hours during operating hours.
            </p>
          </div>
          <Illustration name="contact-us" priority className="max-w-[380px] mx-auto" />
        </div>
      </section>

      <section className="py-16 bg-surface-white">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <div className="grid md:grid-cols-12 gap-10 items-start">
            {/* Form */}
            <div className="md:col-span-7 bg-surface-white rounded-xl shadow-tactile border border-navy-deep/5 p-8 md:p-10">
              <h2 className="text-headline-h3 font-bold text-navy-deep mb-8">Send us a message</h2>

              {sent ? (
                <div className="text-center py-12">
                  <div className="w-16 h-16 rounded-full bg-emerald-100 flex items-center justify-center mx-auto mb-4">
                    <span className="material-symbols-outlined text-emerald-600 text-3xl">check_circle</span>
                  </div>
                  <h3 className="text-headline-h3 font-bold text-navy-deep mb-2">
                    Your message is ready to send
                  </h3>
                  <p className="text-on-surface-variant mb-6">
                    We&apos;ve opened your email app with the enquiry filled in — press send
                    there and we&apos;ll reply within 2 business hours.
                  </p>
                  <p className="text-on-surface-variant text-sm">
                    Nothing happened?{" "}
                    <a href={CONTACT_EMAIL_HREF} className="text-accent-deep font-body-strong hover:underline">
                      Email us directly at {CONTACT_EMAIL}
                    </a>{" "}
                    or{" "}
                    <a href={CONTACT_PHONE_HREF} className="text-accent-deep font-body-strong hover:underline">
                      call {CONTACT_PHONE_DISPLAY}
                    </a>.
                  </p>
                </div>
              ) : (
                <form onSubmit={handleSubmit} className="space-y-5">
                  <div className="grid md:grid-cols-2 gap-5">
                    <div>
                      <label htmlFor="contact-name" className="font-label-caps text-on-surface-variant uppercase text-xs mb-2 block">
                        Full Name
                      </label>
                      <input
                        id="contact-name"
                        name="name"
                        type="text"
                        required
                        autoComplete="name"
                        placeholder="John Doe"
                        className="w-full bg-mist border border-navy-deep/10 rounded-lg px-4 py-3 text-navy-deep placeholder:text-on-surface-variant/50 focus:outline-none focus:border-accent-deep focus:ring-2 focus:ring-accent-deep/20 transition-all"
                      />
                    </div>
                    <div>
                      <label htmlFor="contact-email" className="font-label-caps text-on-surface-variant uppercase text-xs mb-2 block">
                        Email Address
                      </label>
                      <input
                        id="contact-email"
                        name="email"
                        type="email"
                        required
                        autoComplete="email"
                        placeholder="john@example.com"
                        className="w-full bg-mist border border-navy-deep/10 rounded-lg px-4 py-3 text-navy-deep placeholder:text-on-surface-variant/50 focus:outline-none focus:border-accent-deep focus:ring-2 focus:ring-accent-deep/20 transition-all"
                      />
                    </div>
                  </div>
                  <div className="grid md:grid-cols-2 gap-5">
                    <div>
                      <label htmlFor="contact-phone" className="font-label-caps text-on-surface-variant uppercase text-xs mb-2 block">
                        Phone Number
                      </label>
                      <input
                        id="contact-phone"
                        name="phone"
                        type="tel"
                        autoComplete="tel"
                        placeholder="+27 00 000 0000"
                        className="w-full bg-mist border border-navy-deep/10 rounded-lg px-4 py-3 text-navy-deep placeholder:text-on-surface-variant/50 focus:outline-none focus:border-accent-deep focus:ring-2 focus:ring-accent-deep/20 transition-all"
                      />
                    </div>
                    <div>
                      <label htmlFor="contact-subject" className="font-label-caps text-on-surface-variant uppercase text-xs mb-2 block">
                        Subject
                      </label>
                      <select id="contact-subject" name="subject" defaultValue="General Inquiry" className="w-full bg-mist border border-navy-deep/10 rounded-lg px-4 py-3 text-navy-deep focus:outline-none focus:border-accent-deep focus:ring-2 focus:ring-accent-deep/20 transition-all">
                        <option>General Inquiry</option>
                        <option>Get a Quote</option>
                        <option>Business Enquiry</option>
                        <option>Support</option>
                      </select>
                    </div>
                  </div>
                  <div>
                    <label htmlFor="contact-message" className="font-label-caps text-on-surface-variant uppercase text-xs mb-2 block">
                      Message
                    </label>
                    <textarea
                      id="contact-message"
                      name="message"
                      rows={5}
                      required
                      placeholder="How can our valet team assist you today?"
                      className="w-full bg-mist border border-navy-deep/10 rounded-lg px-4 py-3 text-navy-deep placeholder:text-on-surface-variant/50 focus:outline-none focus:border-accent-deep focus:ring-2 focus:ring-accent-deep/20 transition-all resize-none"
                    />
                  </div>
                  <button
                    type="submit"
                    className="w-full bg-accent text-on-accent h-[56px] rounded-xl font-body-strong flex items-center justify-center gap-2 hover:opacity-90 active:scale-95 transition-all"
                  >
                    Send Message
                    <span className="material-symbols-outlined">send</span>
                  </button>
                </form>
              )}
            </div>

            {/* Contact details */}
            <div className="md:col-span-5 space-y-5">
              {/* Details card */}
              <div className="bg-surface-white rounded-xl shadow-tactile border border-navy-deep/5 p-7">
                <h3 className="text-headline-h3 font-bold text-navy-deep mb-6">Contact Details</h3>
                <div className="space-y-5">
                  {[
                    { icon: "location_on", title: "Cape Town HQ", lines: HQ_ADDRESS_LINES, href: HQ_MAPS_HREF },
                    { icon: "mail", title: "Email Us", lines: [CONTACT_EMAIL], href: CONTACT_EMAIL_HREF },
                    { icon: "phone", title: "Phone Support", lines: [CONTACT_PHONE_DISPLAY], href: CONTACT_PHONE_HREF },
                    { icon: "schedule", title: "Operating Hours", lines: OPENING_HOURS_LINES },
                  ].map(({ icon, title, lines, href }) => (
                    <div key={title} className="flex items-start gap-4">
                      <div className="w-10 h-10 rounded-full bg-accent/10 flex items-center justify-center shrink-0">
                        <span className="material-symbols-outlined text-accent-deep">{icon}</span>
                      </div>
                      <div>
                        <p className="font-body-strong text-navy-deep text-sm">{title}</p>
                        {lines.map((l) =>
                          href ? (
                            <a
                              key={l}
                              href={href}
                              className="block text-on-surface-variant text-sm hover:text-accent-deep transition-colors"
                            >
                              {l}
                            </a>
                          ) : (
                            <p key={l} className="text-on-surface-variant text-sm">{l}</p>
                          )
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Map */}
              <div className="rounded-xl overflow-hidden shadow-tactile border border-navy-deep/5 bg-mist">
                {/*
                  Google's keyless embed endpoint, so the map is a real map
                  rather than the icon-in-a-grey-box placeholder that stood
                  here — and it needs no API key or billing account to render.
                */}
                <iframe
                  title="StrongBox Cape Town headquarters on Google Maps"
                  src="https://www.google.com/maps?q=Kensington%2C+Cape+Town%2C+7504&output=embed"
                  loading="lazy"
                  referrerPolicy="no-referrer-when-downgrade"
                  className="w-full h-52 border-0 block"
                />
                <a
                  href={HQ_MAPS_HREF}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center justify-center gap-2 py-3 text-accent-deep uppercase tracking-widest font-label-caps text-xs hover:bg-accent/10 transition-colors"
                >
                  <span className="material-symbols-outlined text-base">open_in_new</span>
                  Open in Google Maps
                </a>
              </div>

              {/* Social */}
              {SOCIAL_LINKS.some((s) => s.href) && (
                <div className="bg-surface-white rounded-xl shadow-tactile border border-navy-deep/5 p-6">
                  <p className="text-on-surface-variant text-sm mb-4">Connect With Us</p>
                  <div className="flex gap-3">
                    {SOCIAL_LINKS.filter((s) => s.href).map(({ platform, label, href }) => (
                      <a
                        key={platform}
                        href={href}
                        target="_blank"
                        rel="noopener noreferrer"
                        aria-label={label}
                        title={label}
                        className="w-12 h-12 rounded-full border border-outline-variant flex items-center justify-center text-navy-deep hover:border-accent-deep hover:text-accent-deep transition-colors"
                      >
                        <SocialIcon platform={platform} />
                      </a>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </section>

      {/*
        Where we actually go. Structured data claims `areaServed` for the whole
        metro, and Google expects a claim in the markup to be visible on the
        page — this is that page. It is also the answer to the question every
        caller opens with, so it earns its place regardless of the crawler.
      */}
      <section className="py-16 bg-mist">
        <div className="max-w-container-max mx-auto px-6 md:px-margin-desktop">
          <h2 className="text-headline-h2 font-bold text-navy-deep mb-3">
            Where we collect and deliver
          </h2>
          <p className="text-on-surface-variant text-body-main max-w-2xl mb-8">
            One facility, in {HQ_SUBURB}, and a fleet that covers the whole of
            Cape Town. You never travel to us — we come to your door, and these are
            the suburbs we run to regularly. If yours is not listed, call us; it is
            usually still a yes.
          </p>
          <ul className="flex flex-wrap gap-2">
            {SERVICE_AREAS.map((area) => (
              <li
                key={area}
                className="bg-surface-white border border-navy-deep/10 rounded-full px-4 py-2 text-sm text-navy-deep"
              >
                {area}
              </li>
            ))}
          </ul>
        </div>
      </section>
    </>
  );
}
