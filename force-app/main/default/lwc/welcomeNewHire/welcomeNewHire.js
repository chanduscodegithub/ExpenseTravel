import { LightningElement } from 'lwc';
import html2canvasLib from '@salesforce/resourceUrl/html2canvas';
import { loadScript } from 'lightning/platformResourceLoader';

export default class WelcomeNewHire extends LightningElement {
    imageUrl = 'https://avatars.mds.yandex.net/get-shedevrum/12154225/img_3c2e97e8f57711ee97860a0d9f74bed2/orig';
    isHtml2CanvasInitialized = false;

    async renderedCallback() {
        if (this.isHtml2CanvasInitialized) return;
        
        try {
            await loadScript(this, html2canvasLib);
            this.isHtml2CanvasInitialized = true;
            console.log('html2canvas loaded');
        } catch (error) {
            console.error('Failed to load html2canvas', error);
        }
    }

async captureImage() {
    try {
        const elementToCapture = this.template.querySelector('.capture-content');
        if (!elementToCapture) {
            console.error('Element not found');
            return;
        }

        // Check if html2canvas can render a simpler element
        const simpleElement = document.createElement('div');
        simpleElement.textContent = 'Test Canvas Rendering';
        simpleElement.style.width = '300px';
        simpleElement.style.height = '200px';
        simpleElement.style.backgroundColor = '#f0f0f0';
        document.body.appendChild(simpleElement);

        // Attempt to capture the simple element first
        const testCanvas = await window.html2canvas(simpleElement, {
            logging: true,
            useCORS: true,
            allowTaint: true,
            scale: 2,
            backgroundColor: '#ffffff',
        });

        if (!(testCanvas instanceof HTMLCanvasElement)) {
            console.error('Test canvas is not a valid HTMLCanvasElement');
            return;
        }

        console.log('Test Canvas rendered successfully:', testCanvas);

        // Proceed with capturing the actual content
        const rect = elementToCapture.getBoundingClientRect();
        
        // Create a temporary div outside shadow DOM
        const tempDiv = document.createElement('div');
        tempDiv.style.position = 'absolute';
        tempDiv.style.left = '-9999px';
        tempDiv.innerHTML = `
            <div style="width: ${rect.width}px; background: white; padding: 20px; box-shadow: 0 0 10px rgba(0,0,0,0.1);">
                <div style="text-align: center;">
                    <h1 style="color: #1b396a; font-size: 24px; margin-bottom: 20px;">Let's Welcome</h1>
                    <img src="${this.imageUrl}" style="max-width: 300px; border-radius: 8px; margin: 20px 0;" crossorigin="anonymous"/>
                    <h2 style="color: #2196f3; font-size: 20px; margin: 20px 0;">Hemanjali Sood</h2>
                    <p style="color: #555; font-size: 16px;">Hemanjali has joined us as a "CX Cloud Senior Developer".</p>
                </div>
            </div>
        `;
        
        document.body.appendChild(tempDiv);

        // Wait for image to load
        const img = tempDiv.querySelector('img');
        await new Promise((resolve) => {
            if (img.complete) resolve();
            else img.onload = resolve;
        });

        // Capture the temporary div using html2canvas and ensure the promise resolves to a valid canvas
        const canvas = await window.html2canvas(tempDiv, {
            useCORS: true,
            allowTaint: true,
            backgroundColor: '#ffffff',
            scale: 2,
            logging: true
        });

        // Check if the result is a valid canvas element
        if (!(canvas instanceof HTMLCanvasElement)) {
            console.error('Generated object is not a valid HTMLCanvasElement');
            return;
        }

        console.log('Captured Canvas:', canvas);

        // Clean up
        document.body.removeChild(tempDiv);

        // Generate image data URL
        const dataUrl = canvas.toDataURL('image/png');
        if (!dataUrl) {
            console.error('Failed to generate image data URL');
            return;
        }

        // Download the image
        const link = document.createElement('a');
        link.download = 'welcome.png';
        link.href = dataUrl;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

    } catch (error) {
        console.error('Error during capture:', error);
    }
}


}