# What to remember when setting up Caddy

You need to set up your own Caddyfile in the path below
```zsh
/opt/homebrew/etc/Caddyfile
```

After that you can start caddy using brew

```zsh
brew services start caddy
```

and if you update the Caddyfile you can use

```zsh
brew services restart caddy
```

## WARNING: remember to use the certificate file for root of the caddy also
Pay attention to `tls internal` you can see that this will generate a self sign root cert
```zsh
cd $HOME/Library/Application\ Support/Caddy/certificates/local/
```

