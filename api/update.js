export default async function handler(req, res) {
  const POSTHOG_API_KEY = process.env.POSTHOG_API_KEY;
  const SLACK_BOT_TOKEN = process.env.SLACK_BOT_TOKEN;

  const phRes = await fetch("https://app.posthog.com/api/projects/372936/query", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${POSTHOG_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      query: {
        kind: "HogQLQuery",
        query: "select count(*) from persons where properties.Approved = false",
      },
    }),
  });

  const phData = await phRes.json();
  const rawCount = phData.results[0][0];
  const total = rawCount + 273;

  const message = `Rebel Audio Waitlist Update 📋\n✅ Total waitlisted: ${total}`;

  await fetch("https://slack.com/api/chat.postMessage", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${SLACK_BOT_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      channel: "#lattice-rebel",
      text: message,
    }),
  });

  res.status(200).json({ ok: true, total });
}
