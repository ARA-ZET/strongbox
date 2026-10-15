const test = require("node:test");
const assert = require("node:assert/strict");
const { sendMail, transportFor, JSON_TRANSPORT } = require("../src/mailer");

const options = (transport) => ({
  transport, from: "StrongBox <info@strongbox.co.za>",
  replyTo: "info@strongbox.co.za",
});
const mail = {
  to: "dee@x.co",
  message: { subject: "You're invited", text: "Hi", html: "<p>Hi</p>" },
};

test("sends with the configured sender and reports the message id", async () => {
  const sent = [];
  const transport = { sendMail: async (m) => {
    sent.push(m);
    return { messageId: "<1@x>", accepted: [m.to], rejected: [] };
  } };
  assert.deepEqual(await sendMail(mail, options(transport)),
      { state: "SUCCESS", messageId: "<1@x>" });
  assert.equal(sent[0].from, "StrongBox <info@strongbox.co.za>");
  assert.equal(sent[0].replyTo, "info@strongbox.co.za");
  assert.equal(sent[0].html, "<p>Hi</p>");
});

test("failures are reported, never thrown", async () => {
  const broken = { sendMail: async () => {
    throw new Error("Invalid login: 535 Authentication failed");
  } };
  const result = await sendMail(mail, options(broken));
  assert.equal(result.state, "ERROR");
  assert.match(result.error, /535 Authentication failed/);

  const refused = { sendMail: async (m) =>
    ({ messageId: "x", accepted: [], rejected: [m.to] }) };
  assert.match((await sendMail(mail, options(refused))).error, /dee@x\.co/);
});

test("explains when sending is not set up", async () => {
  assert.equal(transportFor(""), null);
  const result = await sendMail(mail, options(null));
  assert.equal(result.state, "ERROR");
  assert.match(result.error, /not set up/);
  assert.match((await sendMail({ to: "a@b.co" },
      options({ sendMail: async () => ({}) }))).error, /subject/);
});

test("the json test transport builds the message without sending", async () => {
  const result = await sendMail(mail, options(transportFor(JSON_TRANSPORT)));
  assert.equal(result.state, "SUCCESS");
});
