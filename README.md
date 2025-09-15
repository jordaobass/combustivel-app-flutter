# 🚗 Combustível App

**Aplicativo inteligente para controle de gastos com combustível e gerenciamento de veículos**

Um app completo desenvolvido em Flutter para rastrear abastecimentos, analisar consumo e otimizar custos com combustível.

![Flutter](https://img.shields.io/badge/Flutter-3.22+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue?logo=dart)
![Material Design 3](https://img.shields.io/badge/Material%20Design-3-green)
![iOS Style](https://img.shields.io/badge/iOS-Like%20Design-lightgrey)

## ✨ Funcionalidades

### 🚙 Gerenciamento de Veículos
- ✅ Cadastro de múltiplos veículos
- ✅ Cores de identificação personalizadas
- ✅ Dados de capacidade do tanque e consumo esperado
- ✅ Status ativo/inativo
- ✅ Filtragem por veículo individual

### ⛽ Registro de Abastecimentos
- ✅ Data em formato brasileiro (dd/MM/yyyy)
- ✅ Tipos de combustível (Gasolina, Etanol, Diesel, GNV)
- ✅ Odômetro com validação automática
- ✅ Cálculo automático do valor total
- ✅ Opção de tanque cheio ou parcial
- ✅ Posto de gasolina (opcional)
- ✅ Interface limpa e intuitiva

### 📊 Dashboard e Analytics
- ✅ Resumo dos gastos do mês atual
- ✅ Métricas de consumo médio
- ✅ Análise de eficiência por tipo de combustível
- ✅ Comparativo de preços
- ✅ Filtros por período e veículo

### 🎨 Design Moderno
- ✅ Material Design 3
- ✅ Cores inspiradas no iOS (verde #30D158)
- ✅ Efeito liquid glass na bottom bar
- ✅ Ícone customizado com design temático
- ✅ Animações suaves e feedback visual

## 🏗️ Arquitetura

Projeto desenvolvido seguindo **Clean Architecture** com padrões modernos:

```
lib/
├── core/                    # Configurações centrais
│   ├── constants/          # Cores, strings, dimensões
│   ├── routes/             # Navegação com GoRouter
│   ├── theme/              # Material Design 3
│   └── widgets/            # Componentes reutilizáveis
├── data/                   # Camada de dados
│   ├── models/             # Modelos Hive + code generation
│   └── repositories/       # Repositórios offline-first
├── domain/                 # Regras de negócio
│   ├── entities/           # Entidades do domínio
│   └── usecases/           # Casos de uso
└── presentation/           # Interface e estado
    ├── pages/              # Telas organizadas por feature
    ├── widgets/            # Componentes específicos
    └── cubits/             # Gerenciamento de estado (BLoC)
```

## 🛠️ Tecnologias

### Core
- **Flutter 3.22+** - Framework multiplataforma
- **Dart 3.0+** - Linguagem de programação
- **Material Design 3** - Sistema de design

### Gerenciamento de Estado
- **BLoC/Cubit** - Arquitetura reativa
- **ValueListenableBuilder** - Estado local eficiente

### Armazenamento
- **Hive** - Banco NoSQL offline-first
- **Code Generation** - Adaptadores automáticos (.g.dart)

### Navegação
- **GoRouter** - Roteamento declarativo
- **URLs amigáveis** - Navegação baseada em rotas

### UI/UX
- **Custom Painting** - Ícone personalizado
- **BackdropFilter** - Efeitos de vidro
- **Animações implícitas** - Transições suaves

## 🚀 Como Executar

### Pré-requisitos
```bash
# Flutter SDK 3.22+
flutter --version

# Dispositivo/emulador Android/iOS
flutter devices
```

### Instalação
```bash
# Clonar repositório
git clone <repository-url>
cd combustivel_app

# Instalar dependências
flutter pub get

# Gerar código Hive
flutter pub run build_runner build --delete-conflicting-outputs

# Executar
flutter run
```

### Comandos Úteis
```bash
# Análise de código
flutter analyze

# Testes
flutter test

# Build para produção
flutter build apk --release
flutter build ios --release

# Hot reload/restart
r  # Hot reload
R  # Hot restart
```

## 📱 Capturas de Tela

### Dashboard
- Resumo financeiro do mês
- Métricas de consumo
- Acesso rápido às funcionalidades

### Veículos
- Lista com identificação visual
- Ações de editar/excluir
- Botão fixo para adicionar

### Abastecimentos
- Formulário intuitivo e validado
- Data em formato brasileiro
- Cálculo automático de valores

### Analytics
- Gráficos de consumo
- Comparativos de eficiência
- Filtros por período

## 🎯 Padrões de Qualidade

### Código Limpo
- ✅ SOLID principles aplicados
- ✅ Zero cores hardcoded (tudo em AppColors)
- ✅ Widgets reutilizáveis
- ✅ Separação clara de responsabilidades

### Performance
- ✅ Offline-first com Hive
- ✅ Lazy loading de dados
- ✅ Widgets const quando possível
- ✅ ValueListenableBuilder para atualizações eficientes

### Manutenibilidade
- ✅ Arquitetura escalável
- ✅ Código bem documentado
- ✅ Testes unitários
- ✅ Análise estática sem warnings

## 🔄 Roadmap

### Próximas Funcionalidades
- [ ] Backup/restore de dados
- [ ] Sincronização em nuvem
- [ ] Lembretes de manutenção
- [ ] Relatórios em PDF
- [ ] Dark mode
- [ ] Localização de postos
- [ ] Comparativo de preços regional

### Melhorias Técnicas
- [ ] Testes de integração
- [ ] CI/CD pipeline
- [ ] App Store/Play Store
- [ ] Métricas de uso
- [ ] Crashlytics

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🤝 Contribuição

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📞 Contato

- **Desenvolvedor:** Claude Code
- **Tecnologia:** Flutter & Dart
- **Arquitetura:** Clean Architecture + SOLID

---

**🚗 Controle seus gastos com combustível de forma inteligente!**