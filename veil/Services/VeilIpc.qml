import QtQuick
import Quickshell.Io

Item {
    id: root

    required property var controller
    visible: false

    IpcHandler {
        target: "plugin:veil"

        function toggleFocused(): bool {
            return root.controller.toggleFocused();
        }

        function hide(address: string): bool {
            return root.controller.hideWindow(address);
        }

        function restore(address: string): bool {
            return root.controller.restoreWindow(address);
        }

        function publishTarget(providerId: string, priority: int, windowId: string, groupId: string, metadataJson: string): bool {
            return root.controller.publishTarget(providerId, priority, windowId, groupId, metadataJson);
        }

        function clearTarget(providerId: string): bool {
            return root.controller.clearTarget(providerId);
        }

        function openRestoreMenu(): bool {
            return root.controller.openRestoreMenu();
        }

        function list(): string {
            return root.controller.list();
        }

        function debugState(): string {
            return root.controller.debugState();
        }
    }
}
