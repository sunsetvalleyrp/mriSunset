/* ============================================================
   sunset_qjobs — UI Script
   Suporta tipo "paradas" (ônibus) e tipo "entrega" (caminhão)
   ============================================================ */

   (function () {
    'use strict';

    // --------------------------------------------------------
    //  DOM
    // --------------------------------------------------------
    const panel           = document.getElementById('jobs-panel');
    const jobsTitle       = document.getElementById('jobs-title');
    const btnClose        = document.getElementById('btn-close');
    const mainTabs        = document.querySelectorAll('.main-tab');

    const subviewRotas    = document.getElementById('subview-rotas');
    const routesGrid      = document.getElementById('routes-grid');

    const subviewRanking  = document.getElementById('subview-ranking');
    const btnRefreshRank  = document.getElementById('btn-refresh-rank');
    const rankingLoading  = document.getElementById('ranking-loading');
    const rankingEmpty    = document.getElementById('ranking-empty');
    const rankingTableWrap = document.getElementById('ranking-table-wrap');
    const rankingTbody    = document.getElementById('ranking-tbody');

    const viewActive      = document.getElementById('view-active');
    const activeJobName   = document.getElementById('active-job-name');
    const activeRouteName = document.getElementById('active-route-name');
    const activeProgressFill  = document.getElementById('active-progress-fill');
    const activeProgressLabel = document.getElementById('active-progress-label');
    const btnFinishJob    = document.getElementById('btn-finish-job');
    const btnCancelJob    = document.getElementById('btn-cancel-job');

    const toast           = document.getElementById('toast');

    // --------------------------------------------------------
    //  Estado
    // --------------------------------------------------------
    let currentTab     = 'rotas';
    let currentView    = 'main';
    let rankingCache   = null;
    let activeJobData  = null;
    let toastTimer     = null;

    let jobId          = null;
    let jobRotas       = [];
    let jobTipo        = 'paradas';

    // --------------------------------------------------------
    //  Mensagens do Lua
    // --------------------------------------------------------
    window.addEventListener('message', function (event) {
        const data = event.data;
        if (data.action === 'showMenu')    openMenu(data.jobs, data.activeJob, data.panelTitle);
        if (data.action === 'hideMenu')    closeMenu();
        if (data.action === 'updateStop')  onStopUpdate(data.stop, data.totalStops, data.tipo);
        if (data.action === 'jobFinished') onJobFinished(data.pago, data.xp);
        if (data.action === 'canFinalize') {
            btnFinishJob.classList.toggle('hidden', !data.value);
        }
    });

    // --------------------------------------------------------
    //  Abrir / fechar
    // --------------------------------------------------------
    function openMenu(jobs, activeJob, panelTitle) {
        const job = jobs && jobs[0];
        if (job) {
            jobId    = job.id;
            jobRotas = job.rotas || [];
            jobTipo  = job.tipo || 'paradas';
        }

        rankingCache = null;

        // Atualiza título do painel
        if (panelTitle) jobsTitle.textContent = panelTitle;

        if (activeJob) {
            activeJobData = activeJob;
            showActiveView();
        } else {
            showMainView('rotas');
        }

        panel.classList.remove('hidden');
    }

    function closeMenu() {
        panel.classList.add('hidden');
    }

    // --------------------------------------------------------
    //  Views
    // --------------------------------------------------------
    function showMainView(tab) {
        currentView = 'main';
        viewActive.classList.add('hidden');
        subviewRotas.classList.remove('hidden');
        subviewRanking.classList.add('hidden');
        setMainTab(tab || 'rotas');
        renderRoutesGrid(jobRotas);
    }

    function showActiveView() {
        currentView = 'active';
        subviewRotas.classList.add('hidden');
        subviewRanking.classList.add('hidden');
        viewActive.classList.remove('hidden');
        btnFinishJob.classList.add('hidden');
        renderActiveView();
    }

    // --------------------------------------------------------
    //  Abas: ROTAS | RANKING
    // --------------------------------------------------------
    function setMainTab(tab) {
        currentTab = tab;
        mainTabs.forEach(function (btn) {
            btn.classList.toggle('active', btn.dataset.tab === tab);
        });

        if (tab === 'rotas') {
            subviewRotas.classList.remove('hidden');
            subviewRanking.classList.add('hidden');
        } else {
            subviewRotas.classList.add('hidden');
            subviewRanking.classList.remove('hidden');
            if (!rankingCache) loadRanking();
            else renderRankingTable(rankingCache);
        }
    }

    mainTabs.forEach(function (btn) {
        btn.addEventListener('click', function () { setMainTab(btn.dataset.tab); });
    });

    // --------------------------------------------------------
    //  Ranking
    // --------------------------------------------------------
    function loadRanking() {
        if (!jobId) return;

        rankingLoading.classList.remove('hidden');
        rankingEmpty.classList.add('hidden');
        rankingTableWrap.classList.add('hidden');
        btnRefreshRank.classList.add('spinning');

        fetch('https://sunset_qjobs/getRanking', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ jobId: jobId }),
        })
        .then(function (r) { return r.json(); })
        .then(function (data) { rankingCache = data; renderRankingTable(data); })
        .catch(function () { rankingLoading.classList.add('hidden'); rankingEmpty.classList.remove('hidden'); })
        .finally(function () { btnRefreshRank.classList.remove('spinning'); });
    }

    btnRefreshRank.addEventListener('click', function () { rankingCache = null; loadRanking(); });

    function renderRankingTable(list) {
        rankingLoading.classList.add('hidden');
        if (!list || list.length === 0) {
            rankingEmpty.classList.remove('hidden');
            rankingTableWrap.classList.add('hidden');
            return;
        }
        rankingEmpty.classList.add('hidden');
        rankingTableWrap.classList.remove('hidden');
        rankingTbody.innerHTML = '';

        list.forEach(function (row, i) {
            const pos       = i + 1;
            const tr        = document.createElement('tr');
            if (pos <= 3)   tr.classList.add('rank-' + pos);
            const posClass  = pos === 1 ? 'gold' : pos === 2 ? 'silver' : pos === 3 ? 'bronze' : 'normal';
            const posText   = pos === 1 ? '🥇' : pos === 2 ? '🥈' : pos === 3 ? '🥉' : pos;
            const nameClass = pos <= 3 ? 'rank-' + pos + '-name' : '';
            const distKm    = row.total_distance ? (row.total_distance / 1000).toFixed(1) + ' km' : '0.0 km';

            tr.innerHTML =
                '<td class="td-pos ' + posClass + '">' + posText + '</td>' +
                '<td class="td-name ' + nameClass + '">' + escapeHtml(row.player_name) + '</td>' +
                '<td class="td-xp">'  + (row.total_xp || 0) + ' XP</td>' +
                '<td class="td-sec">' + (row.routes_completed || 0) + ' rotas</td>' +
                '<td class="td-sec">' + distKm + '</td>';
            rankingTbody.appendChild(tr);
        });
    }

    // --------------------------------------------------------
    //  Grid de rotas
    // --------------------------------------------------------
    function renderRoutesGrid(rotas) {
        routesGrid.innerHTML = '';
        rotas.forEach(function (rota, i) {
            routesGrid.appendChild(buildRouteCard(rota, i));
        });
    }

    function buildRouteCard(rota, index) {
        const card = document.createElement('div');
        card.className = 'route-card' + (rota.bloqueado ? ' route-locked' : '');
        card.style.animationDelay = (index * 50) + 'ms';

        const paradasLabel = jobTipo === 'entrega' ? '1 ENTREGA'
            : jobTipo === 'sedex' ? (rota.paradas + ' ENTREGAS')
            : (rota.paradas + ' PARADAS');

        if (rota.bloqueado) {
            card.innerHTML =
                '<div class="route-card-head">' +
                    '<span class="route-card-name">' + escapeHtml(rota.label) + '</span>' +
                    '<span class="route-card-badge">' + paradasLabel + '</span>' +
                '</div>' +
                '<div class="route-lock-center">' +
                    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="32" height="32"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>' +
                    '<span>Nível ' + rota.nivelMinimo + ' necessário</span>' +
                '</div>';
            return card;
        }

        const xpRow = (rota.xpMin && rota.xpMax)
            ? '<div class="route-card-pay">' +
                '<span class="route-card-pay-label">REPUTAÇÃO AO CONCLUIR</span>' +
                '<span class="route-card-pay-value">' + rota.xpMin + ' – ' + rota.xpMax + ' XP</span>' +
              '</div>'
            : (rota.xp
                ? '<div class="route-card-pay">' +
                    '<span class="route-card-pay-label">REPUTAÇÃO AO CONCLUIR</span>' +
                    '<span class="route-card-pay-value">' + rota.xp + ' XP</span>' +
                  '</div>'
                : '');

        card.innerHTML =
            '<div class="route-card-head">' +
                '<span class="route-card-name">' + escapeHtml(rota.label) + '</span>' +
                '<span class="route-card-badge">' + paradasLabel + '</span>' +
            '</div>' +
            '<p class="route-card-desc">' + escapeHtml(rota.descricao) + '</p>' +
            '<div class="route-card-pay">' +
                '<span class="route-card-pay-label">PAGAMENTO AO CONCLUIR</span>' +
                '<span class="route-card-pay-value">$' + rota.payMin + ' – $' + rota.payMax + '</span>' +
            '</div>' +
            xpRow +
            '<button class="btn-start-route">INICIAR ROTA</button>';

        card.querySelector('.btn-start-route').addEventListener('click', function (e) {
            e.stopPropagation();
            fetch('https://sunset_qjobs/startJob', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ jobId: jobId, routeId: rota.id }),
            }).catch(function () {});
            closeMenu();
        });

        return card;
    }

    // --------------------------------------------------------
    //  View turno ativo
    // --------------------------------------------------------
    function renderActiveView() {
        if (!activeJobData) return;
        const rota = jobRotas.find(function (r) { return r.id === activeJobData.routeId; });
        activeJobName.textContent   = jobsTitle.textContent;
        activeRouteName.textContent = rota ? rota.label : (activeJobData.routeId || '');
        updateProgressBar(activeJobData.stop, activeJobData.totalStops, activeJobData.tipo);
    }

    function updateProgressBar(stop, total, tipo) {
        const done = stop <= total ? stop : total;
        const pct  = total > 0 ? Math.round((done / total) * 100) : 0;
        activeProgressFill.style.width = pct + '%';

        if (tipo === 'sedex') {
            activeProgressLabel.textContent = done >= total
                ? 'Retorne à central para finalizar!'
                : ('Entregas: ' + done + ' / ' + total + ' — ' + pct + '% concluído');
        } else if (tipo === 'entrega') {
            activeProgressLabel.textContent = done >= total
                ? '✅ Entregue! Retorne à garagem.'
                : '📦 Dirija até o ponto de entrega.';
        } else {
            activeProgressLabel.textContent = done >= total
                ? 'Retorne à garagem!'
                : ('Parada ' + done + ' / ' + total + ' — ' + pct + '% concluído');
        }
    }

    function onStopUpdate(stop, total, tipo) {
        if (activeJobData) {
            activeJobData.stop = stop;
            activeJobData.totalStops = total;
            activeJobData.tipo = tipo;
        }
        if (currentView === 'active') updateProgressBar(stop, total, tipo);
    }

    function onJobFinished(pago, xp) {
        activeJobData = null;
        if (!panel.classList.contains('hidden')) showMainView('rotas');
    }

    // --------------------------------------------------------
    //  Botões de ação
    // --------------------------------------------------------
    btnFinishJob.addEventListener('click', function () {
        fetch('https://sunset_qjobs/finalizeJob', {
            method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}',
        }).catch(function () {});
        closeMenu();
    });

    btnCancelJob.addEventListener('click', function () {
        fetch('https://sunset_qjobs/cancelJob', {
            method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}',
        }).catch(function () {});
        closeMenu();
    });

    btnClose.addEventListener('click', function () {
        fetch('https://sunset_qjobs/closeMenu', {
            method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}',
        }).catch(function () {});
        closeMenu();
    });

    document.addEventListener('keyup', function (e) {
        if (e.key !== 'Escape') return;
        fetch('https://sunset_qjobs/closeMenu', {
            method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}',
        }).catch(function () {});
        closeMenu();
    });

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