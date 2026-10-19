package {{androidIdentifier}}

import android.content.Context

object QuickGate {
    private const val PREFS = "{{projectName}}_native"
    private const val KEY = "quickPlay"

    fun enabled(context: Context): Boolean =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(KEY, true)

    fun set(context: Context, on: Boolean) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean(KEY, on).apply()
    }
}
