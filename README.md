# blabla DLALF

Web para organizar los viajes en coche de la familia: quien conduce publica su trayecto y los demás se apuntan a las plazas libres.

## Cómo está hecha

| Parte | Servicio | Qué hace |
|---|---|---|
| Código | GitHub | Guarda `index.html`, `config.js` y `supabase.sql` |
| Base de datos | Supabase (PostgreSQL) | Tablas `viajes` y `plazas`, función `apuntar()` |
| Despliegue | Vercel | Publica la web estática a partir del repositorio |

- `index.html`: la web completa (HTML, CSS y JavaScript). Usa `supabase-js` desde jsDelivr.
- `config.js`: URL del proyecto de Supabase y clave pública.
- `supabase.sql`: crea las tablas, los permisos (RLS) y la función `apuntar()`, que impide apuntar a más gente de la que cabe.

No necesita cuentas: cada persona escribe su nombre la primera vez y el navegador lo recuerda.

## Volver a desplegar

Cada cambio que se sube a GitHub lo publica Vercel automáticamente.
