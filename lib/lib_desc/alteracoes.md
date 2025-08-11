# O que falta?

## Catálogo de Complexidade
Descreva de forma clara e objetiva a pontuação de complexidade do seu projeto. Se puder faça a correlação do widget do seu projeto.

## Arquivo check_um.md
Crie o arquivo check_um.md com os seguintes dados:  
- Nome(s) de quem participou da atividade;  
- Quantidade de desafios realizados até o momento;  
- (Opcional) Dificuldades enfrentadas, aprendizados e outros pontos que queira destacar.  

## Arquivo check_dois.md
Indique quais arquivos devo ver para avaliar o check_dois.

## Pasta de Andamento
Coloque tude nesta pasta. Utilize para armazenar informações relacionadas à evolução do seu projeto.


## Tabela Complexidade

| Critério | Pontos | Descrição |
|---------|--------|-----------|
| **Cadastro simples** | 1 ponto (máx. 5) | CRUD básico, sem relações entre entidades. <br>Ex.: cadastro de produtos, clientes. |
| **Cadastro com associação (1:N)** | 3 pontos | Relacionamento pai-filho. <br>Ex.: cliente → pedidos. |
| **Cadastro com associação (N:N)** | 6 pontos | Cadastro com tabela intermediária (relacionamento muitos-para-muitos). <br>Ex.: aluno ↔ disciplinas. |
| **Consumo de API externa com persistência local e remota sincronizada** | 3 pontos | Consumo de dados externos (via `http`, `dio` etc.) com salvamento local (`Hive`, `SQLite`) e/ou remoto (Firebase). |
| **Notificações (locais ou push)** | 1 ponto | Ex.: `flutter_local_notifications`, Firebase Messaging. |
| **Chamada externa de aplicativos** | 1 ponto | Abertura de apps como e-mail, telefone, WhatsApp ou navegador. <br>Ex.: `url_launcher`. |
| **Organização em camadas (MVC, MVVM ou similar)** | 2 pontos | Separação entre interface, lógica de negócio e dados. <br>Ex.: uso de controllers, services, models. |
| **Integração com mapas, geolocalização ou sensores** | 3 pontos | Uso de recursos do dispositivo. <br>Ex.: `google_maps_flutter`, `geolocator`, `camera`, `sensor_plus`. |
| **Dashboard com gráficos dinâmicos** | 3 pontos | Gráficos que representam dados atualizados. <br>Ex.: `fl_chart`, `syncfusion_flutter_charts`. |
| **Relatórios com filtros e agrupamentos** | 2 pontos | Relatórios interativos com filtros por data, categoria etc. |
| **Componentização com campo de opções inteligentes** | 2 pontos | Campos com busca otimizada, cadastro rápido e atualização automática. <br>Ex.: `DropdownSearch`, `autocomplete`, `TextFormField` + `showDialog`. |
| **CI/CD – Integração e entrega contínua** | 8 pontos | Integração contínua com GitHub Actions e Entrega contínua com distribuição com Firebase App Distribution (CD). |

---

>>> É obrigatório ter pelo menos uma funcionalidade com persistência associativa.
