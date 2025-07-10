# Usa uma imagem oficial que já tem o Flutter SDK
FROM cirrusci/flutter:stable

# Cria uma pasta para o aplicativo dentro do contentor
WORKDIR /app

# Copia os ficheiros de configuração primeiro
COPY pubspec.yaml .
COPY pubspec.lock .

# Baixa as dependências do Flutter
RUN flutter pub get

# Copia o resto do código do aplicativo
COPY . .

# Constrói a versão web do aplicativo
RUN flutter build web

# --- Etapa de Servidor ---
# Agora, usamos uma imagem leve com um servidor web (nginx)
FROM nginx:alpine

# Copia os ficheiros da web que foram construídos na etapa anterior
COPY --from=0 /app/build/web /usr/share/nginx/html

# Expõe a porta 80 para o tráfego web
EXPOSE 80

# O comando para iniciar o servidor nginx
CMD ["nginx", "-g", "daemon off;"]
