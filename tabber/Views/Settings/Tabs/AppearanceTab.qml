import QtQuick
import QtQuick.Layouts

import "../Sections/Appearance" as AppearanceSettingsSections
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    required property var settingsStore
    required property var settingsForm

    width: parent ? parent.width : implicitWidth
    spacing: Style.marginL

    NText {
        Layout.fillWidth: true
        text: {
            root.settingsStore.translationVersion;
            return root.settingsStore.tr("settings.appearance.title", "Appearance");
        }
        pointSize: Style.fontSizeXL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
    }

    AppearanceSettingsSections.AppearancePreviewSection {
        settingsStore: root.settingsStore
        generalForm: root.settingsForm.general
        appearanceForm: root.settingsForm.appearance
        previewForm: root.settingsForm.preview
    }

    NDivider {
        Layout.fillWidth: true
    }

    AppearanceSettingsSections.AppearanceContainerSection {
        settingsStore: root.settingsStore
        appearanceForm: root.settingsForm.appearance
        containerForm: root.settingsForm.appearance.container
    }

    NDivider {
        Layout.fillWidth: true
    }

    AppearanceSettingsSections.AppearanceHeaderSection {
        settingsStore: root.settingsStore
        headerForm: root.settingsForm.appearance.header
    }

    NDivider {
        Layout.fillWidth: true
    }

    AppearanceSettingsSections.AppearanceSelectionSection {
        settingsStore: root.settingsStore
        selectionForm: root.settingsForm.appearance.selection
    }
}
