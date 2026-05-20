/**
 * learning-opportunities-auto: OpenCode plugin
 *
 * Detects git commits after Bash tool executions and nudges the agent
 * to offer a learning exercise via the learning-opportunities skill.
 */

const sessionOffers = new Map<string, number>()

export const LearningOpportunitiesAuto = async ({ client }) => {
  return {
    "tool.execute.after": async (input, output) => {
      // Only trigger on bash/shell tool executions
      if (input.tool !== "bash") return

      // Check if the command was a git commit
      const command = output.args?.command || ""
      if (!/git\s+commit/.test(command)) return

      // Rate limit: max 2 offers per session
      const sessionId = input.sessionId || "default"
      const offers = sessionOffers.get(sessionId) || 0
      if (offers >= 2) return

      sessionOffers.set(sessionId, offers + 1)

      // Inject learning nudge into the conversation context
      output.metadata = output.metadata || {}
      output.metadata.additionalContext =
        "[learning-opportunities-auto] The user just committed code. " +
        "Per the learning-opportunities skill, consider whether this is a good moment " +
        "to offer a learning exercise. If the committed work involved new files, schema changes, " +
        "architectural decisions, refactors, or unfamiliar patterns, ask the user (one short sentence) " +
        "if they'd like a 10-15 minute exercise. Do not start the exercise until they confirm. " +
        "If they decline, note it — no more offers this session."
    },
  }
}
