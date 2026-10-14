const catalogData = [
    { id: 1, name: "Куртка Oversize Неоновая", category: "Верхняя одежда", price: 8990, image: "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&q=80", isTop: true },
    { id: 2, name: "Брюки Карго Wide Leg", category: "Брюки", price: 4590, image: "https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=600&q=80", isBottom: true },
    { id: 3, name: "Худи Базовое Black", category: "Свитшоты", price: 3990, image: "https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=600&q=80", isTop: true },
    { id: 4, name: "Кроссовки Chunky Matrix", category: "Обувь", price: 12990, image: "https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=600&q=80" },
    { id: 5, name: "Футболка Acid Wash", category: "Футболки", price: 1990, image: "https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600&q=80", isTop: true },
    { id: 6, name: "Джинсы Baggy Vintage", category: "Джинсы", price: 5490, image: "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600&q=80", isBottom: true }
];

function getCart() {
    return JSON.parse(localStorage.getItem('verge_cart')) || [];
}

function saveCart(cart) {
    localStorage.setItem('verge_cart', JSON.stringify(cart));
    updateCartBadge();
}

function updateCartBadge() {
    const cart = getCart();
    const count = cart.reduce((sum, item) => sum + item.quantity, 0);
    const badge = document.getElementById('cart-badge');
    if (badge) {
        badge.innerText = count;
        badge.style.display = count > 0 ? 'flex' : 'none';
    }
}

function addToCart(id, notify = true) {
    const product = catalogData.find(p => p.id === id);
    let cart = getCart();
    const existing = cart.find(item => item.id === id);
    
    if (existing) {
        existing.quantity++;
    } else {
        cart.push({ ...product, quantity: 1 });
    }
    saveCart(cart);
    if (notify) showToast(`${product.name} добавлено в корзину`);
}

function showToast(message) {
    let toast = document.getElementById('toast');
    if (!toast) {
        toast = document.createElement('div');
        toast.id = 'toast';
        toast.className = 'bg-white text-black font-bold px-6 py-3 rounded-full shadow-2xl flex items-center gap-3';
        toast.innerHTML = `<span id="toast-msg"></span>`;
        document.body.appendChild(toast);
    }
    document.getElementById('toast-msg').innerText = message;
    toast.classList.add('show');
    setTimeout(() => toast.classList.remove('show'), 2500);
}

function formatPrice(price) {
    return price.toLocaleString('ru-RU') + ' ₽';
}

document.addEventListener('DOMContentLoaded', updateCartBadge);
