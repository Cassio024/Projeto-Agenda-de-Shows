# --- Etapa de Construção (Build Stage) ---
# ATUALIZAÇÃO FINAL: Usa uma imagem do Docker profissional e bem mantida
FROM bluefireteam/flutter:stable AS build

# Define o diretório de trabalho
WORKDIR /app

# Copia os ficheiros de configuração e baixa as dependências do Flutter
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Agora copia o resto do código do aplicativo
COPY . .

# Constrói a versão web otimizada do aplicativo
RUN flutter build web --release

# --- Etapa de Servidor (Serve Stage) ---
# Usa uma imagem leve com um servidor web (nginx)
FROM nginx:alpine

# Copia os ficheiros da web que foram construídos na etapa anterior
COPY --from=build /app/build/web /usr/share/nginx/html

# Copia o nosso ficheiro de configuração personalizado para o Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expõe a porta 80 para o tráfego web
EXPOSE 80

# O comando para iniciar o servidor nginx
CMD ["nginx", "-g", "daemon off;"]
