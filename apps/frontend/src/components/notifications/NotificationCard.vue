<template>
    <div class="relative">
        <span class="absolute right-6 top-5 text-gray-500 cursor-pointer" @click="destroyNotification(notification)">
            <i class="fas fa-times" />
        </span>
        <div class="bg-white rounded-lg border-gray-300 border shadow-lg p-3">
            <component :is="body.content" v-bind="{ ...body.props }" />
        </div>
    </div>
</template>

<script lang="ts" setup>
    import { computed } from 'vue';
    import { Notification, NotificationType, ProgressNotification } from '@/types/notifications';
    import InfoNotification from '@/components/notifications/InfoNotification.vue';
    import ProgressNotificationComponent from '@/components/notifications/ProgressNotification.vue';
    import { destroyNotification } from '@/store/notificiationStore';

    interface IProp {
        notification: Notification;
    }

    interface IBody {
        content: any;
        props: {
            notification: Notification;
        };
    }

    const props = defineProps<IProp>();

    const body = computed<IBody>(() => {
        if (props.notification.type === NotificationType.Info)
            return {
                content: InfoNotification,
                props: { notification: props.notification as Notification },
            };

        if (props.notification.type === NotificationType.Progress)
            return {
                content: ProgressNotificationComponent,
                props: { notification: props.notification as ProgressNotification },
            };
    });
</script>

<style scoped></style>
