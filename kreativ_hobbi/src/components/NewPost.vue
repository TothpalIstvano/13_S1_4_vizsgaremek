<template>
<main class="new-post-page">
    <div class="page-header">
        <h1 class="title">Új poszt hozzáadása</h1>
        <p class="subtitle">Töltsd ki az alábbi mezőket egy új blogposzt létrehozásához</p>
    </div>
    
    <div v-if="notification.show" 
         :class="['notification', notification.type]"
         @click="notification.show = false">
        <i :class="notificationIcon" class="notification-icon"></i>
        <span class="notification-message">{{ notification.message }}</span>
    </div>
    
    <div class="container">
        <form @submit.prevent="submitForm" class="post-form">
            <div class="form-section">
                <label for="postTitle" class="form-label">
                    <!--<i class="pi pi-pencil form-label-icon"></i>-->
                    Poszt címe
                    <span class="required-indicator">*</span>
                </label>
                <InputText 
                    id="postTitle" 
                    v-model="post.title" 
                    placeholder="Add meg a poszt címét..." 
                    class="w-full mb-6" 
                    :class="{ 'p-invalid': post.title === '' && formTouched }"
                />
                <small class="form-hint">Adj egy rövid, informatív címet a posztodnak</small>
            </div>

            <div class="form-section">
                <label for="postCimkek" class="form-label">
                    <!--<i class="pi pi-tags form-label-icon"></i>-->
                    Címkék
                    <span class="required-indicator">*</span>
                </label>
                <MultiSelect
                    id="postCimkek"
                    v-model="selectedTags" 
                    :options="tagOptions" 
                    optionLabel="name" 
                    placeholder="Válassz címkét (több is választható)" 
                    display="chip" 
                    filter
                    class="w-full mb-6"
                />
                <small class="form-hint">Válassz témához kapcsolódó címkéket a jobb kereshetőségért</small>
            </div>

            <div class="form-section">
                <label for="postSubtext" class="form-label">
                    <!--<i class="pi pi-pencil form-label-icon"></i>-->
                    Poszt rövid leírása
                </label>
                <InputText 
                    id="postSubtext"
                    placeholder="Add meg a poszt leírását..." 
                    class="w-full mb-6" 
                    :class="{ 'p-invalid': post.title === '' && formTouched }"
                />
                <small class="form-hint">Adj egy rövid, tömör leírást a posztod tartalmáról (ennek hiányában a poszt első pár mondata kerül a helyére)</small>
            </div>

            <div class="form-section">
                <label class="form-label">
                    <!--<i class="pi pi-file-edit form-label-icon"></i>-->
                    Tartalom
                    <span class="required-indicator">*</span>
                </label>
                <Editor 
                    v-model="post.content" 
                    editorStyle="height: 400px"
                    class="mb-6 editor-container"
                    :pt="{
                        toolbar: { class: 'editor-toolbar' },
                        content: { style: { 'min-height': '250px', 'font-family': 'inherit' } }
                    }"
                />
                <small class="form-hint">Használhatsz formázást és linkeket a tartalomban</small>
            </div>

            <div class="form-section">
                <label class="form-label">
                    Képek feltöltése
                </label>
                <!--<FileUpload name="demo[]" url="/api/upload" @upload="onAdvancedUpload($event)" :multiple="true" accept="image/*" :maxFileSize="1000000" showUploadButton="false">
                    <template #empty>
                        <span>Húzd ide/Illeszd be a fájlaidat a feltöltéshez.</span>
                    </template>
                </FileUpload>-->
                <FileUpload 
                    ref="fileUploadRef"
                    name="demo[]" 
                    url="/api/upload" 
                    @upload="onAdvancedUpload($event)" 
                    @select="onFileSelect($event)"
                    @before-send="onBeforeSend($event)"
                    :multiple="true" 
                    accept="image/*" 
                    :maxFileSize="5000000" 
                    :showUploadButton="false"
                    :showCancelButton="true"
                    :auto="true"
                    :chooseLabel="'Fájlok kiválasztása'"
                    :cancelLabel="'Mégse'"
                    :pt="{
                        root: { class: 'custom-fileupload' },
                        chooseButton: { 
                            class: 'custom-choose-button'
                        },
                        cancelButton: {
                            class: 'custom-cancel-button'
                        }
                    }"
                >
                    <template #empty>
                        <div class="drag-drop-area">
                            <i class="pi pi-cloud-upload" style="font-size: 3rem; color: #667eea; margin-bottom: 1rem;"></i>
                            <p>Húzd ide a fájlaidat vagy kattints a feltöltéshez</p>
                        </div>
                    </template>
                </FileUpload>
                <small class="form-hint">Támogatott formátumok: JPG, PNG, GIF. Maximális fájlméret: 5MB.</small>
            </div>

            <div class="form-actions">
                <Button
                    type="button" 
                    label="Mentés piszkozatként" 
                    icon="pi pi-pencil" 
                    class="draft-button"
                    @click="vissza"
                </Button>
                <Button
                    type="submit" 
                    label="Poszt feltöltése" 
                    icon="pi pi-check" 
                    class="submit-button"
                    :disabled="!isFormValid"
                    :class="{ 'p-button-success': isFormValid }">
                </Button>
                <Button
                    type="button" 
                    label="Visszaállítás" 
                    icon="pi pi-refresh" 
                    class="p-button-outlined reset-button"
                    @click="resetForm"
                    severity="secondary"> 
                </Button>
            </div>
        </form>        
    </div>
</main>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import MultiSelect from 'primevue/multiselect';
import Editor from 'primevue/editor';
import InputText from 'primevue/inputtext';
import Button from 'primevue/button';
import axios from 'axios';
import FileUpload from 'primevue/fileupload';

const post = ref({
    title: '',
    content: ''
});

const formTouched = ref(false);

const selectedTags = ref([]);
const tagOptions = ref([]); // Initialize as empty array

const isFormValid = computed(() => {
    return post.value.title.trim() !== '' && post.value.content.trim() !== '';
});

const notification = ref({
    show: false,
    message: '',
    type: 'info'
});

const notificationIcon = computed(() => {
    const icons = {
        success: 'pi pi-check-circle',
        error: 'pi pi-times-circle',
        warn: 'pi pi-exclamation-triangle',
        info: 'pi pi-info-circle'
    };
    return icons[notification.value.type] || 'pi pi-info-circle';
});

const showNotification = (type, message, duration = 3500) => {
    notification.value = {
        show: true,
        message,
        type
    };
    
    setTimeout(() => {
        notification.value.show = false;
    }, duration);
};

const fetchTagsFromDatabase = async () => {
    try {
        const response = await axios.get('/api/cimkek');
        
        // Transform the data to match your MultiSelect format
        tagOptions.value = response.data.map(tag => ({
            id: tag.id,
            name: tag.nev,
            code: tag.nev.toLowerCase().replace(/\s+/g, '_')
        }));
    } catch (error) {
        console.error('Error fetching tags:', error);
        showNotification('error', 'Nem sikerült betölteni a címkéket');
    }
};

const submitForm = async () => {
    formTouched.value = true;
    
    if (!isFormValid.value) {
        showNotification('warn', 'Kérjük töltsd ki a kötelező mezőket!');
        return;
    }
    
    const formData = {
        title: post.value.title,
        content: post.value.content,
        tags: selectedTags.value.map(tag => tag.id) // Send only tag IDs to backend
    };
    
    try {
        console.log('Submitting post:', formData);
        
        // TODO: Replace with your actual API endpoint for creating posts
        // const response = await axios.post('/api/posts', formData);
        
        showNotification('success', 'Poszt sikeresen mentve!');
        
        post.value = { title: '', content: '' };
        selectedTags.value = [];
        formTouched.value = false;
        
    } catch (error) {
        console.error('Error submitting post:', error);
        showNotification('error', 'Nem sikerült menteni a posztot');
    }
};

const resetForm = () => {
    post.value = { title: '', content: '' };
    selectedTags.value = [];
    formTouched.value = false;
    showNotification('info', 'Űrlap visszaállítva');
};

onMounted(() => {
    fetchTagsFromDatabase();
});
</script>

<style scoped>
*, *::before, *::after {
  box-sizing: border-box;
}

:deep() {
    /* PrimeVue component customizations */
    .p-inputtext {
        border: 2px solid #e2e8f0;
        border-radius: 10px;
        padding: 14px 16px;
        font-size: 16px;
        transition: all 0.3s ease;
        background-color: white;
    }
    
    .p-inputtext:focus {
        border-color: #4d8af0;
        box-shadow: 0 0 0 3px rgba(77, 138, 240, 0.1);
        outline: none;
    }
    
    .p-inputtext.p-invalid {
        border-color: #f87171;
    }
    
    .p-multiselect {
        border: 2px solid #e2e8f0;
        border-radius: 10px;
        transition: all 0.3s ease;
        width: 40%;
    }
    
    .p-multiselect:not(.p-disabled):hover {
        border-color: #cbd5e0;
    }
    
    .p-multiselect:not(.p-disabled).p-focus {
        border-color: #4d8af0;
        box-shadow: 0 0 0 3px rgba(77, 138, 240, 0.1);
    }
    
    .p-multiselect-panel {
        border-radius: 10px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
    }
    
    .p-multiselect-chip .p-chip {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border-radius: 20px;
        padding: 6px 12px;
        font-weight: 500;
    }
    
    .p-button {
        padding: 14px 28px;
        font-size: 16px;
        font-weight: 600;
        border-radius: 10px;
        transition: all 0.3s ease;
        border: none;
    }
    
    .p-button:not(:disabled):hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
    }
    
    .p-button-success {
        background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    }
    
    .p-button-success:not(:disabled):hover {
        background: linear-gradient(135deg, #059669 0%, #047857 100%);
    }
    
    .p-button-outlined {
        background: transparent;
        border: 2px solid #cbd5e0;
        color: #4a5568;
    }
    
    .p-button-outlined:not(:disabled):hover {
        background: #f7fafc;
        border-color: #a0aec0;
    }
    
    .editor-toolbar {
        border: 2px solid #e2e8f0;
        border-bottom: none;
        border-radius: 10px 10px 0 0;
        padding: 12px;
        background: #f8fafc;
    }
    
    .p-editor-container .p-editor-content {
        border: 2px solid #e2e8f0;
        border-top: none;
        border-radius: 0 0 10px 10px;
        min-height: 250px;
    }
}

.drag-drop-area {
    border: 2px dashed #cbd5e0;
    border-radius: 10px;
    padding: 40px 20px;
    text-align: center;
    cursor: pointer;
    transition: all 0.3s ease;
    background-color: #f8fafc;
    margin-bottom: 1rem;
}

.drag-drop-area:hover {
    border-color: #4d8af0;
    background-color: #f0f7ff;
}

.drag-drop-area p {
    color: #718096;
    font-size: 16px;
    margin: 0;
}


:deep(.custom-choose-button) {
    background-color: #4d8af0 !important;
    border: none !important;
    color: white !important;
    border-radius: 10px !important;
    padding: 12px 24px !important;
    font-weight: 600 !important;
    transition: all 0.3s ease !important;
}

:deep(.custom-choose-button:hover) {
    background-color: #764ba2 !important;
    transform: translateY(-2px) !important;
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1) !important;
}

:deep(.custom-cancel-button) {
    background-color: #ef4444;
}

:deep(.custom-cancel-button:disabled) {
    background-color: #ef4444;
}


:deep(.p-fileupload-content .p-fileupload-files .p-fileupload-row) {
    background: #f8fafc;
    border-radius: 8px;
    margin-bottom: 8px;
    padding: 12px;
    border: 1px solid #e2e8f0;
}

:deep(.p-fileupload-content .p-button) {
    background: #f89595 !important;
    border: none !important;
    border-radius: 6px !important;
    padding: 6px 12px !important;
    font-size: 14px !important;
}

:deep(.p-fileupload-content .p-button:hover) {
    background: #ef4444 !important;
    color: white;
}

#postTitle {
    width: 30%;
}

#postSubtext {
    width: 50%;
}

.new-post-page {
    min-height: 100vh;
    /*background: rgb(223, 220, 220);*/
    padding: 10px 20px;
    text-align: center;
}

.page-header {
    margin-bottom: 40px;
    text-align: center;
}

.title {
    font-weight: 800;
    font-size: 48px;
    -webkit-background-clip: text;
    background-clip: text;
    color: black;
    margin-bottom: 12px;
}

.subtitle {
    font-size: 18px;
    color: #718096;
    max-width: 600px;
    margin: 0 auto;
    line-height: 1.6;
}

.notification {
    position: fixed;
    top: 30px;
    right: 30px;
    padding: 20px 25px;
    border-radius: 12px;
    color: white;
    font-weight: 600;
    z-index: 1000;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
    animation: slideIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    cursor: pointer;
    max-width: 400px;
    display: flex;
    align-items: center;
    gap: 12px;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.2);
}

.notification.success {
    background: linear-gradient(135deg, rgba(16, 185, 129, 0.95) 0%, rgba(5, 150, 105, 0.95) 100%);
    border-left: 5px solid #059669;
}

.notification.error {
    background: linear-gradient(135deg, rgba(239, 68, 68, 0.95) 0%, rgba(220, 38, 38, 0.95) 100%);
    border-left: 5px solid #dc2626;
}

.notification.warn {
    background: linear-gradient(135deg, rgba(245, 158, 11, 0.95) 0%, rgba(217, 119, 6, 0.95) 100%);
    border-left: 5px solid #d97706;
}

.notification.info {
    background: linear-gradient(135deg, rgba(59, 130, 246, 0.95) 0%, rgba(29, 78, 216, 0.95) 100%);
    border-left: 5px solid #1d4ed8;
}

.notification-icon {
    font-size: 20px;
}

.notification-message {
    flex: 1;
}

@keyframes slideIn {
    from {
        transform: translateX(100%) translateY(-20px);
        opacity: 0;
    }
    to {
        transform: translateX(0) translateY(0);
        opacity: 1;
    }
}

@keyframes fadeOut {
    to {
        opacity: 0;
        transform: translateY(-20px);
    }
}

.container {
    border-radius: 20px;
    background: white;
    padding: 50px;
    text-align: left;
    max-width: 80%;
    margin: 0 auto;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.08);
    border: 1px solid rgba(226, 232, 240, 0.6);
}

.post-form {
    display: flex;
    flex-direction: column;
    gap: 32px;
}

.form-section {
    position: relative;
}

.form-label {
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 700;
    font-size: 22px;
    color: #2d3748;
    margin-bottom: 12px;
    letter-spacing: -0.3px;
}

.form-label-icon {
    color: #4d8af0;
    font-size: 20px;
}

.required-indicator {
    color: #f87171;
}

.form-hint {
    display: block;
    margin-top: 8px;
    color: #718096;
    font-size: 14px;
    font-style: italic;
}

.form-actions {
    display: flex;
    gap: 16px;
    justify-content: flex-end;
    margin-top: 40px;
    padding-top: 30px;
    border-top: 2px solid #f1f5f9;
}

.submit-button {
    min-width: 180px;
}

.reset-button {
    min-width: 140px;
}

.draft-button {
    background-color: #667eea;
}

/* Responsive adjustments */
@media (max-width: 1024px) {
    .container {
        padding: 40px 30px;
        max-width: 90%;
    }
    
    .title {
        font-size: 42px;
    }
}

@media (max-width: 768px) {
    .new-post-page {
        padding: 20px 15px;
    }
    
    .container {
        padding: 30px 20px;
        border-radius: 15px;
    }
    
    .title {
        font-size: 36px;
    }
    
    .subtitle {
        font-size: 16px;
        padding: 0 15px;
    }
    
    .notification {
        left: 15px;
        right: 15px;
        max-width: none;
        top: 15px;
    }
    
    .form-actions {
        flex-direction: column;
        gap: 12px;
    }
    
    .submit-button, .reset-button {
        width: 100%;
    }
    
    :deep() {
        .p-button {
            width: 100%;
            justify-content: center;
        }
    }
}

@media (max-width: 480px) {
    .title {
        font-size: 32px;
    }
    
    .container {
        padding: 25px 15px;
    }
    
    .form-label {
        font-size: 16px;
    }
    
    :deep() {
        .p-inputtext {
            padding: 12px 14px;
            font-size: 15px;
        }
    }
}
</style>