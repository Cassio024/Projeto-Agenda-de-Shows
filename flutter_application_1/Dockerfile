# --- Etapa de Construção (Build Stage) ---
# ATUALIZAÇÃO: Usa uma imagem do Docker mais recente com Flutter 3.x
FROM leoafarias/flutter:3.19.6 AS build

# Cria uma pasta para o aplicativo dentro do contentor
WORKDIR /app

# Copia os ficheiros de configuração. Copiar o .lock garante consistência.
COPY pubspec.yaml pubspec.lock ./

# Baixa as dependências do Flutter
RUN flutter pub get

# Agora copia o resto do código do aplicativo
COPY . .

# Constrói a versão web otimizada do aplicativo
RUN flutter build web --release

# --- Etapa de Servidor (Serve Stage) ---
# Agora, usamos uma imagem leve com um servidor web (nginx)
FROM nginx:alpine

# Copia os ficheiros da web que foram construídos na etapa anterior
COPY --from=build /app/build/web /usr/share/nginx/html

# Copia o nosso ficheiro de configuração personalizado para o Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expõe a porta 80 para o tráfego web
EXPOSE 80

# O comando para iniciar o servidor nginx
CMD ["nginx", "-g", "daemon off;"]
