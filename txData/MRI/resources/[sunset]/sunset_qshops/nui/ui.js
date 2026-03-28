/* ============================================================
   sunset_qshops — UI Script
   ============================================================ */

(function () {
    'use strict';

    // --------------------------------------------------------
    //  DOM
    // --------------------------------------------------------
    const panel       = document.getElementById('shop-panel');
    const shopTitle   = document.getElementById('shop-title');
    const filterTabs  = document.getElementById('filter-tabs');
    const searchInput = document.getElementById('search-input');
    const shopGrid    = document.getElementById('shop-grid');
    const shopEmpty   = document.getElementById('shop-empty');
    const btnClose    = document.getElementById('btn-close');
    const toast       = document.getElementById('toast');

    // Modal de quantidade
    const qtyBackdrop  = document.getElementById('qty-backdrop');
    const qtyModal     = document.getElementById('qty-modal');
    const qtyItemName  = document.getElementById('qty-item-name');
    const qtyUnitPrice = document.getElementById('qty-unit-price');
    const qtyValue     = document.getElementById('qty-value');
    const qtyTotal     = document.getElementById('qty-total-price');
    const qtyDec       = document.getElementById('qty-dec');
    const qtyInc       = document.getElementById('qty-inc');
    const qtyCancel    = document.getElementById('qty-cancel');
    const qtyConfirm   = document.getElementById('qty-confirm');

    // --------------------------------------------------------
    //  Estado
    // --------------------------------------------------------
    let allItems       = [];
    let activeCategory = 'todos';
    let imgDir         = '';
    let toastTimer     = null;

    // Estado do modal
    let pendingItem    = null;  // { item, name, compra, quantidade }
    let selectedQty    = 1;
    const MAX_QTY      = 99;

    // --------------------------------------------------------
    //  Mensagens do Lua
    // --------------------------------------------------------
    window.addEventListener('message', function (event) {
        const data = event.data;
        if (data.action === 'showMenu') openMenu(data.shopName, data.items, data.imgDir);
        if (data.action === 'hideMenu') closeMenu();
    });

    // --------------------------------------------------------
    //  Abrir / fechar menu
    // --------------------------------------------------------
    function openMenu(shopName, items, dir) {
        imgDir         = dir || '';
        allItems       = items || [];
        activeCategory = 'todos';

        shopTitle.textContent = shopName || 'LOJA';
        searchInput.value     = '';

        buildFilterTabs(allItems);
        renderGrid(allItems);

        panel.classList.remove('hidden');
        searchInput.focus();
    }

    function closeMenu() {
        closeQtyModal();
        panel.classList.add('hidden');
        allItems = [];
    }

    // --------------------------------------------------------
    //  Filtros
    // --------------------------------------------------------
    function buildFilterTabs(items) {
        const categories = ['todos'];
        items.forEach(function (item) {
            if (item.category && !categories.includes(item.category)) {
                categories.push(item.category);
            }
        });

        const labelMap = {
            todos: 'TODOS', bebidas: 'BEBIDAS', comidas: 'COMIDAS',
            utilidades: 'UTILIDADES', armas: 'ARMAS', materiais: 'MATERIAIS',
            acessorios: 'ACESSÓRIOS', ilegais: 'ILEGAIS',
            eletronicos: 'ELETRÔNICOS', veiculos: 'VEÍCULOS',
        };

        filterTabs.innerHTML = '';
        categories.forEach(function (cat) {
            const btn = document.createElement('button');
            btn.className        = 'filter-btn' + (cat === 'todos' ? ' active' : '');
            btn.dataset.category = cat;
            btn.textContent      = labelMap[cat] || cat.toUpperCase();
            btn.addEventListener('click', function () { setCategory(cat); });
            filterTabs.appendChild(btn);
        });
    }

    function setCategory(cat) {
        activeCategory = cat;
        filterTabs.querySelectorAll('.filter-btn').forEach(function (btn) {
            btn.classList.toggle('active', btn.dataset.category === cat);
        });
        applyFilters();
    }

    function applyFilters() {
        const query = searchInput.value.trim().toLowerCase();
        const filtered = allItems.filter(function (item) {
            const matchCat  = activeCategory === 'todos' || item.category === activeCategory;
            const matchText = !query ||
                item.name.toLowerCase().includes(query) ||
                (item.descricao && item.descricao.toLowerCase().includes(query));
            return matchCat && matchText;
        });
        renderGrid(filtered);
    }

    // --------------------------------------------------------
    //  Grid
    // --------------------------------------------------------
    function renderGrid(items) {
        shopGrid.innerHTML = '';
        if (items.length === 0) { shopEmpty.classList.remove('hidden'); return; }
        shopEmpty.classList.add('hidden');
        items.forEach(function (item, index) {
            shopGrid.appendChild(buildCard(item, index));
        });
    }

    function buildCard(item, index) {
        const card = document.createElement('div');
        card.className = 'item-card';
        card.style.animationDelay = (index * 30) + 'ms';

        const imagePath = imgDir + item.item + '.png';
        const descricao = item.descricao || '';
        const qty = item.quantidade > 1
            ? '<div class="card-qty">Leva <span>' + item.quantidade + 'x</span> por compra</div>'
            : '';

        card.innerHTML =
            '<div class="card-head">' +
                '<span class="card-name">' + escapeHtml(item.name) + '</span>' +
                '<span class="card-price">' +
                    '<svg viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">' +
                        '<circle cx="8" cy="8" r="7.5" stroke="none"/>' +
                        '<text x="8" y="12" text-anchor="middle" font-size="9" font-family="sans-serif" font-weight="bold" fill="#000">$</text>' +
                    '</svg>' +
                    item.compra +
                '</span>' +
            '</div>' +
            '<div class="card-img">' +
                '<img src="' + imagePath + '" alt="' + escapeHtml(item.name) + '" onerror="this.style.opacity=\'0.2\'" />' +
            '</div>' +
            (descricao ? '<p class="card-desc">' + escapeHtml(descricao) + '</p>' : '') +
            qty +
            '<button class="btn-buy" data-item="' + escapeHtml(item.item) + '">COMPRAR ITEM</button>';

        card.querySelector('.btn-buy').addEventListener('click', function (e) {
            e.stopPropagation();
            openQtyModal(item);
        });

        return card;
    }

    // --------------------------------------------------------
    //  Modal de quantidade
    // --------------------------------------------------------
    function openQtyModal(item) {
        pendingItem  = item;
        selectedQty  = 1;

        qtyItemName.textContent  = item.name;
        qtyUnitPrice.textContent = '$' + item.compra + ' por unidade';
        updateQtyDisplay();

        qtyBackdrop.classList.remove('hidden');
        qtyModal.classList.remove('hidden');
    }

    function closeQtyModal() {
        qtyBackdrop.classList.add('hidden');
        qtyModal.classList.add('hidden');
        pendingItem = null;
        selectedQty = 1;
    }

    function updateQtyDisplay() {
        if (!pendingItem) return;
        const total = pendingItem.compra * selectedQty;
        qtyValue.textContent = selectedQty;
        qtyTotal.textContent = '$' + total;
        qtyDec.disabled = selectedQty <= 1;
        qtyInc.disabled = selectedQty >= MAX_QTY;
    }

    qtyDec.addEventListener('click', function () {
        if (selectedQty > 1) { selectedQty--; updateQtyDisplay(); }
    });

    qtyInc.addEventListener('click', function () {
        if (selectedQty < MAX_QTY) { selectedQty++; updateQtyDisplay(); }
    });

    qtyCancel.addEventListener('click', closeQtyModal);

    qtyBackdrop.addEventListener('click', closeQtyModal);

    qtyConfirm.addEventListener('click', function () {
        if (!pendingItem) return;

        const item = pendingItem;
        const qty  = selectedQty;

        closeQtyModal();

        // Uma única chamada com a quantidade total
        fetch('https://sunset_qshops/buyItem', {
            method:  'POST',
            headers: { 'Content-Type': 'application/json' },
            body:    JSON.stringify({ itemName: item.item, qty: qty }),
        }).catch(function () {});

        showToast(
            'Comprando ' + qty + 'x ' + item.name + ' por $' + (item.compra * qty) + '...',
            'success', 2500
        );
    });

    // --------------------------------------------------------
    //  Fechar com X e ESC
    // --------------------------------------------------------
    btnClose.addEventListener('click', function () {
        fetch('https://sunset_qshops/closeMenu', {
            method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}',
        }).catch(function () {});
        closeMenu();
    });

    document.addEventListener('keyup', function (e) {
        if (e.key === 'Escape') {
            if (!qtyModal.classList.contains('hidden')) {
                closeQtyModal();
            } else if (!panel.classList.contains('hidden')) {
                fetch('https://sunset_qshops/closeMenu', {
                    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}',
                }).catch(function () {});
                closeMenu();
            }
        }
    });

    // --------------------------------------------------------
    //  Pesquisa
    // --------------------------------------------------------
    searchInput.addEventListener('input', applyFilters);

    // --------------------------------------------------------
    //  Toast
    // --------------------------------------------------------
    function showToast(msg, type, duration) {
        toast.textContent = msg;
        toast.className   = 'show ' + (type || '');
        if (toastTimer) clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { toast.className = 'hidden'; }, duration || 2500);
    }

    // --------------------------------------------------------
    //  Escape HTML
    // --------------------------------------------------------
    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;').replace(/</g, '&lt;')
            .replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    }

})();
