<template>
    <iframe
        :src="computedUrl"
        allow="microphone; camera"
        style="
            position: relative;
            top: 0;
            left: 0;
            bottom: 0;
            right: 0;
            width: 100%;
            height: 100%;
            border: none;
            margin: 0;
            padding: 0;
            overflow: hidden;
            z-index: 999999;
        "
    >
        Your browser doesn't support iframes
    </iframe>
</template>

<script setup lang="ts">
    import { computed } from 'vue';
    import { useAuthState } from '@/store/authStore';
    import { useRoute } from 'vue-router';

    const { user } = useAuthState();
    const route = useRoute();

    const computedUrl = computed(() => {
        return `https://freeflowconnect.threefold.me/?roomName=${route.params.id}&username=${user.id}.3bot`;
    });
</script>

<style scoped type="text/css"></style>
