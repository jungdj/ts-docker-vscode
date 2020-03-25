FROM node:alpine

LABEL LAST_UPDATED="20200325"

ARG SERVICE_PORT=3000

WORKDIR /usr/src/app

COPY package.json yarn.lock ./
RUN NOYARNPOSTINSTALL=1 yarn
# --frozen-lockfile --production

EXPOSE ${SERVICE_PORT}

COPY . .
RUN yarn build

CMD [ "node", "./dist/index.js" ]