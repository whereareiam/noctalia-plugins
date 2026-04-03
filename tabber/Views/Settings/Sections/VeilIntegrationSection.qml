import QtQuick
import QtQuick.Layouts

import qs.Commons
import qs.Widgets

NBox {
    id: root

    required property var settingsStore
    required property var veilIntegrationForm
    required property var veilPluginState

    Layout.fillWidth: true
    implicitHeight: contentColumn.implicitHeight + Style.marginL * 2
    color: Color.mSurfaceVariant
    forceOpaque: true

    ColumnLayout {
        id: contentColumn

        anchors.fill: parent
        anchors.margins: Style.marginL
        spacing: Style.marginM

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.marginXS

                NText {
                    Layout.fillWidth: true
                    text: {
                        root.settingsStore.translationVersion;
                        return root.settingsStore.tr("settings.integrations.veil.title", "Veil");
                    }
                    pointSize: Style.fontSizeL
                    font.weight: Style.fontWeightBold
                    color: Color.mOnSurface
                }

                NText {
                    Layout.fillWidth: true
                    text: {
                        root.settingsStore.translationVersion;
                        return root.settingsStore.tr("settings.integrations.veil.description", "Controls how Tabber presents and restores Veil-managed windows.");
                    }
                    pointSize: Style.fontSizeS
                    color: Color.mOnSurfaceVariant
                    wrapMode: Text.WordWrap
                }
            }
        }

        NToggle {
            Layout.fillWidth: true
            enabled: root.veilPluginState.isAvailable
            opacity: enabled ? 1.0 : 0.5
            label: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.integrations.veil.enabled.label", "Enable Veil integration");
            }
            description: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.integrations.veil.enabled.description", "Show Veil-hidden windows in Tabber and restore them from the overlay.");
            }
            checked: root.veilIntegrationForm.enabled
            onToggled: checked => root.veilIntegrationForm.enabled = checked
        }

        NToggle {
            Layout.fillWidth: true
            enabled: root.veilPluginState.isAvailable && root.veilIntegrationForm.enabled
            opacity: enabled ? 1.0 : 0.5
            label: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.integrations.veil.highlightHiddenCards.label", "Tint hidden cards");
            }
            description: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.integrations.veil.highlightHiddenCards.description", "Apply a different color treatment to Veil-hidden entries in Tabber.");
            }
            checked: root.veilIntegrationForm.highlightHiddenCards
            onToggled: checked => root.veilIntegrationForm.highlightHiddenCards = checked
        }

        NTextInput {
            Layout.fillWidth: true
            enabled: root.veilPluginState.isAvailable && root.veilIntegrationForm.enabled && root.veilIntegrationForm.highlightHiddenCards
            opacity: enabled ? 1.0 : 0.5
            label: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.integrations.veil.hiddenCardAccentColor.label", "Hidden card accent color");
            }
            description: {
                root.settingsStore.translationVersion;
                return root.settingsStore.tr("settings.integrations.veil.hiddenCardAccentColor.description", "Optional hex color for Veil-hidden cards. Leave empty to derive it from the current Noctalia theme.");
            }
            text: root.veilIntegrationForm.hiddenCardAccentColor
            onTextChanged: root.veilIntegrationForm.hiddenCardAccentColor = text
        }

        NText {
            Layout.fillWidth: true
            text: {
                root.settingsStore.translationVersion;
                if (!root.veilPluginState.isAvailable) {
                    if (root.veilPluginState.isInstalled) {
                        return root.settingsStore.tr("settings.integrations.veil.statusDisabled", "Veil is installed but not enabled in Noctalia. Enable it before using this integration.");
                    }
                    return root.settingsStore.tr("settings.integrations.veil.statusMissing", "Veil is not installed or not discovered by Noctalia. Install and enable it before using this integration.");
                }

                return root.settingsStore.tr("settings.integrations.veil.statusAvailable", "Veil is installed and enabled.");
            }
            pointSize: Style.fontSizeS
            color: root.veilPluginState.isAvailable ? Color.mPrimary : Color.mError
            wrapMode: Text.WordWrap
        }
    }
}
