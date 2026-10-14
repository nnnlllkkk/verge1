function generateRandomLook() {
    const resBox = document.getElementById('smart-result');
    const itemsBox = document.getElementById('smart-items');
    if (!resBox || !itemsBox) return;

    resBox.classList.remove('hidden');
    
    const rTop = tops[Math.floor(Math.random() * tops.length)];
    const rBot = bottoms[Math.floor(Math.random() * bottoms.length)];
    
    itemsBox.innerHTML = `
        <div class="bg-[#121212] p-4 rounded-2xl flex justify-between items-center">
            <span>${rTop.name}</span>
            <span class="text-[#ccff00] font-bold">${formatPrice(rTop.price)}</span>
        </div>
        <div class="bg-[#121212] p-4 rounded-2xl flex justify-between items-center">
            <span>${rBot.name}</span>
            <span class="text-[#ccff00] font-bold">${formatPrice(rBot.price)}</span>
        </div>
    `;
}