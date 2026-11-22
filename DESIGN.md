# Crimson Player — identidade visual aprovada

Referência principal: tela de álbum e Now Playing em duas variações de tema fornecidas pelo usuário (22/11/2026). Não replicar imagens artificiais como conteúdo do player.

## Direção

- Aplicativo Android primeiro, desktop em uma segunda etapa.
- Interface minimalista e musical, espaçamentos contidos, sem grandes banners promocionais.
- Tipografia **Inter**. Fundos monocromáticos, alinhamento preciso, controles acessíveis.
- **Claro:** fundo `#FFFFFF`, texto `#171C26`, subtítulos `#6C7689`, elementos suaves `#A4AAB7`.
- **Escuro:** fundo `#171C26`, texto `#FFFFFF`, superfícies `#202633` e `#272F3E`.
- Capas: somente artwork verdadeiro embutido nos arquivos ou fornecido por fontes licenciadas. Se ausente, placeholder neutro com ícone. Não desenhar capas fake, discos fake ou criar ilustrações em código para fingir imagem.
- Progresso: não gerar forma de onda fictícia. O controle deve representar posição real; uma futura waveform precisa analisar áudio real.
- Biblioteca e álbum: cabeçalhos compactos, capas quadradas reais, lista de faixas, reprodução e shuffle operantes.
- Mini-player: card grafite com texto claro no tema claro; card branco com texto escuro no tema escuro.
- Rodapé: quatro destinos (Início, Buscar, Biblioteca, Hotlist), com indicador deslizante animado via `AnimationController` e transição de ícones. Sem moldura de traço vermelho exagerado.
- Ajustes são acessados pelo botão da tela inicial. Seletor Sistema / Claro / Escuro salvo no dispositivo.
- Nenhum botão deve prometer uma ação falsa. Estados vazios devem informar claramente por que estão vazios.

## Prioridades de qualidade

1. Funcionar: permissões `READ_MEDIA_AUDIO` no Android 13+ e `READ_EXTERNAL_STORAGE` até 12; ler áudio e reproduzi-lo.
2. Experiência do player com mini-player persistente e navegação fluida.
3. Tema escuro/claro na mesma hierarquia visual.
4. Testar em dispositivo real antes de considerar a interface concluída.
5. Catálogo online através de APIs e direitos compatíveis em fase futura; links de áudio autorizados no MVP.
