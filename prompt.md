# Prompt: App Monitor de Combustível (Fuel Track)

## Visão Geral

Desenvolver um aplicativo mobile nativo (Android/iOS) em Flutter para monitoramento completo de gastos com combustível e performance veicular. O app funcionará 100% offline, permitindo que motoristas acompanhem consumo, custos e manutenções de forma detalhada e visual.

## Conceito Principal

Um gerenciador pessoal de combustível que calcula automaticamente km/l, monitora gastos, prevê custos futuros e ajuda a identificar problemas no veículo através de variações no consumo. Tudo com gráficos intuitivos e insights acionáveis.

## Funcionalidades Core

### 1. Registro de Abastecimento

**Entrada Rápida:**
- Quilometragem atual (com validação contra último registro)
- Litros abastecidos
- Valor total e por litro
- Tipo de combustível (Gasolina, Etanol, Diesel, GNV)
- Posto (com GPS automático ou seleção manual)
- Tanque completo ou parcial
- Foto opcional do cupom fiscal

**OCR para Cupom Fiscal (Offline):**
- Reconhecimento de texto local usando ML Kit
- Extração automática de valores
- Confirmação e ajuste manual
- Aprendizado com correções do usuário

### 2. Cálculos Automáticos

**Métricas Calculadas:**
- Km/L instantâneo e médio
- Custo por quilômetro
- Autonomia estimada
- Economia/Gasto comparado ao mês anterior
- Melhor e pior consumo registrado
- Tendência de consumo (melhorando/piorando)

**Previsões:**
- Gasto estimado mensal/anual
- Próximo abastecimento previsto
- Custo para viagens (baseado em distância)
- Economia ao mudar tipo de combustível

### 3. Sistema de Veículos

**Múltiplos Veículos:**
- Perfil detalhado (marca, modelo, ano, motor)
- Foto do veículo
- Capacidade do tanque
- Consumo médio esperado (referência)
- Cor de identificação nos gráficos

**Comparação entre Veículos:**
- Qual é mais econômico
- Custo total por veículo
- Gráficos comparativos lado a lado

### 4. Análise Visual

**Gráficos Interativos:**
- Evolução do consumo (linha)
- Gastos mensais (barras)
- Distribuição por tipo de combustível (pizza)
- Heatmap de dias de abastecimento
- Variação de preços por posto

**Dashboard Principal:**
- Cards com métricas principais
- Mini gráfico de tendência
- Último consumo vs média
- Dias desde último abastecimento
- Economia/gasto do mês

### 5. Gestão de Postos

**Base de Postos Local:**
- Adicionar postos favoritos
- GPS marca localização automaticamente
- Histórico de preços por posto
- Avaliação pessoal (qualidade, atendimento)
- Comparativo de preços entre postos

**Mapa Offline de Abastecimentos:**
- Onde você mais abastece
- Rotas com melhor consumo
- Postos mais econômicos visitados

## Features Avançadas

### Sistema de Manutenção

**Lembretes Inteligentes:**
- Troca de óleo (por km ou tempo)
- Filtros (ar, combustível, cabine)
- Calibragem de pneus
- Revisões programadas
- Alerta baseado em consumo anormal

**Histórico de Manutenções:**
- Tipo de serviço realizado
- Custo e local
- Peças trocadas
- Impacto no consumo pós-manutenção
- Anexar fotos e notas fiscais

### Modo Viagem

**Planejamento:**
- Calcular custo estimado por distância
- Paradas necessárias para abastecimento
- Comparar custo carro vs outros transportes
- Divisão de custos entre passageiros

**Durante a Viagem:**
- Registro rápido de abastecimentos
- Cálculo de consumo em tempo real
- Estatísticas específicas da viagem
- Export de relatório da viagem

### Análise de Economia

**Insights Automáticos:**
- "Você gastou 15% mais este mês"
- "Consumo piorou após 3 meses"
- "Posto X sempre mais caro"
- "Melhor dia para abastecer: quinta"

**Metas e Desafios:**
- Definir meta de economia mensal
- Desafio: reduzir consumo em 10%
- Badges por conquistas
- Ranking pessoal de economia

### Sistema de Alertas

**Notificações Inteligentes:**
- Lembrete de abastecimento (baseado em média)
- Alerta de manutenção próxima
- Consumo fora do padrão
- Meta de economia atingida
- Sugestão de calibragem (economia de até 5%)

## Features Mobile Exclusivas

### Widgets Nativos

**Android:**
- Widget de consumo atual
- Atalho para adicionar abastecimento
- Gráfico mini na home
- Próxima manutenção

**iOS:**
- Widget de dashboard
- Live Activity durante viagem
- Complicações para Apple Watch
- Atalhos da Siri para registro rápido

### Uso de Hardware

**Sensores:**
- GPS para marcar postos automaticamente
- Câmera para OCR e fotos
- NFC para ler tags em veículos (gestão de frota familiar)

**Integração com Sistema:**
- Backup automático local
- Export para apps de planilha
- Compartilhar relatórios via WhatsApp/Email
- Imprimir relatórios via AirPrint/Cloud Print

## Gamificação

### Sistema de Conquistas

**Badges:**
- "Economista" - 3 meses reduzindo consumo
- "Manutenção em Dia" - todas as revisões no prazo
- "Explorador" - 50 postos diferentes
- "Eco Friendly" - uso de etanol/elétrico
- "Veterano" - 1 ano de uso

**Rankings Pessoais:**
- Melhor mês de economia
- Recorde de km/l
- Sequência de manutenções no prazo
- Nível de motorista (bronze, prata, ouro)

## Relatórios e Export

### Tipos de Relatório

**Relatórios Disponíveis:**
- Mensal/Anual completo
- Por veículo específico
- Declaração para IR (combustível dedutível)
- Relatório de manutenções
- Análise de custos para venda do veículo

**Formatos de Export:**
- CSV para Excel
- JSON para backup
- Imagem para compartilhar
- Texto formatado para WhatsApp

## Interface e UX

### Design Principles

**Visual:**
- Cards com gradientes baseados em economia (verde/vermelho)
- Animações suaves para transições
- Gráficos interativos com touch
- Modo escuro/claro automático
- Cores customizáveis por veículo

**Usabilidade:**
- Registro em 3 toques
- Tela inicial com ação principal destacada
- Swipe entre veículos
- Long press para ações rápidas
- Shake para desfazer último registro

## Dados Técnicos

### Armazenamento Local

**Estrutura de Dados:**
- Abastecimentos (data, km, litros, valor)
- Veículos (especificações, foto)
- Postos (localização, preços históricos)
- Manutenções (tipo, custo, km)
- Configurações e preferências
- Cache de cálculos para performance

### Validações e Inteligência

**Validações Automáticas:**
- Km sempre crescente
- Consumo dentro de padrões (alerta se anormal)
- Preços dentro da realidade regional
- Datas consistentes
- Tanque não excede capacidade

## Monetização

### Modelo Sustentável

**Versão Free:**
- 1 veículo
- Últimos 3 meses de dados
- Gráficos básicos
- Export limitado

**Versão Pro (única compra):**
- Veículos ilimitados
- Histórico completo
- Todos os gráficos e análises
- Export ilimitado
- Widgets e temas
- Backup na nuvem (opcional)

## Requisitos Técnicos

### Especificações

- Android 5.0+ (API 21)
- iOS 12.0+
- Armazenamento: ~100MB
- Funciona 100% offline
- Opcional: GPS para postos

### Performance

- Cálculos instantâneos
- Gráficos em 60fps
- App size < 25MB
- Startup < 2 segundos

## Diferenciais Competitivos

### Por que Este App?

- **100% Offline**: Privacidade total, funciona sempre
- **OCR Local**: Não envia dados para servidores
- **Análise Preditiva**: Identifica problemas pelo consumo
- **Multi-veículo**: Família inteira em um app
- **Exportação Completa**: Seus dados são seus

---

**Objetivo Final**: Criar o app definitivo de controle de combustível que não apenas registra gastos, mas ativamente ajuda o usuário a economizar e manter seu veículo em boas condições através de insights inteligentes e interface intuitiva.