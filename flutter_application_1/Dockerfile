# --- Etapa de Construção (Build Stage) ---
# Usa uma imagem oficial que já tem o Flutter SDK
FROM cirrusci/flutter:stable AS build

# Cria uma pasta para o aplicativo dentro do contentor
WORKDIR /app

# Copia apenas o pubspec.yaml para forçar a regeneração do .lock e evitar erros
COPY pubspec.yaml ./
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