const config = {
  autoSlideInterval: 3000, // Tempo de transição automática de slides (ms)
  autoPlay: true, // Valor booleano para controlar a reprodução automática
  musicVolume: 0.05, // Nível de volume padrão (0 = 0%; 0,5 = 50%; 1 = 100%)
  background: {
    type: "video", // "imagem" ou "video" ou "videoPasta"
    url: "pxfNTc5jKiw", // ID do vídeo do YouTube ou caminho do arquivo de imagem ou caminho do arquivo de video
    // videoProvider: "youtube", // Apenas para vídeos do YouTube
  },
  socialMedia: [
    // Máximo de 4 itens
    // {
    //   name: "Web",
    //   icon: "/public/images/web.svg",
    //   link: "https://discord.gg/uEfGD4mmVh",
    // },
    {
      name: "Discord",
      icon: "/public/images/discord.svg",
      link: "https://sunsetvalley.com.br/discord",
    },
    // {
    //   name: "YouTube",
    //   icon: "/public/images/youtube.svg",
    //   link: "https://www.youtube.com/@QBCoreBrasil",
    // },
    // {
    //   name: "Instagram",
    //   icon: "/public/images/insta.svg",
    //   link: "https://discord.gg/uEfGD4mmVh",
    // },
  ],

  images: [
    "/public/images/images_1.png",
    // "/public/images/images_2.png",
    // "/public/images/images_3.png",
    // "/public/images/images_4.png",
    // Você pode adicionar mais imagens
  ],

  songs: [
    // Você pode adicionar mais músicas
    {
      title: "Love Is a Long Road",
      artist: "Tom Petty",
      src: "/public/music/TomPetty.mp3",
      img: "/public/images/love.jpg",
    },
    // {
    //   title: "The Setup",
    //   artist: "Favored Nations",
    //   src: "/public/music/The-Setup.mp3",
    //   img: "/public/images/the-setup.jpg",
    // },
    // {
    //   title: "Welcome The Los Santos",
    //   artist: "Oh No",
    //   src: "/public/music/Welcome-To-Los-Santos.mp3",
    //   img: "/public/images/welcome-lst.jpg",
    // },
  ],

  locales: {
    headerTitle: "Sunset Valley Roleplay", // Título do cabeçalho
    headerSubtitles: [
      "Prepare-se para viver a melhor experiência do Roleplay!",
      // Você pode adicionar mais legendas
    ],
    cardTitles: [
      "Bem-vindo à Sunset Valley Roleplay!",
      "Faça sua carreira na polícia!",
      "Domine o submundo do crime!",
      "Construa um império!",
      // "Entre em nossa Comunidade do Discord!",
      // Você pode adicionar mais títulos
    ],
    cardDescriptions: [
      "Bem-vindo a Sunset Valley Roleplay! Inspirada na atmosfera vibrante de Los Angeles, nossa cidade oferece uma experiência imersiva, realista e levada a sério. Prepare-se para vivenciar histórias únicas com sistemas otimizados e exclusivos.",
      "Qual será o seu legado? Ingresse em uma carreira policial intensa e patrulhe as rodovias, construa um império nos negócios locais ou domine o submundo de Sunset Valley. A economia é balanceada e as escolhas estão em suas mãos.",
      "Sua nova vida começa aqui! Acesse nosso Discord para liberar o seu ID, conhecer a comunidade e ficar por dentro das novidades. Nossa equipe de suporte está sempre ativa para garantir a melhor experiência possível.",
      // Você pode adicionar mais descrições
    ],
    serverGalleryTitle: "Memórias", // Título para a seção da galeria do servidor
    serverGalleryDescription: "São valiosas...", // Descrição da seção da galeria do servidor
    socialMediaText: "Allowlist liberada no Discord", // Texto para seção de mídia social
    socialMediaLinkText: "Sunset Valley", // Texto do link para seção de mídia social
    socialMediaLinkURL: "https://sunsetvalley.com.br/discord", // URL do link para seção de mídia social
  },
};
