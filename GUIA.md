# Guía: publicar PUNTO BLANKS gratis con GitHub + Supabase

**Qué logras:** tu sistema en internet (GitHub Pages), con inicio de sesión y tus datos guardados en la nube (Supabase), accesibles desde cualquier dispositivo.

## Antes de empezar: lo que debes saber (honestidad)

- **GitHub Pages es gratis solo con repositorio PÚBLICO.** Tu código será visible, pero tus **datos no**: viven en Supabase protegidos por inicio de sesión + seguridad por filas (RLS).
- **La clave "Publishable" de Supabase es pública por diseño** y es segura gracias a RLS. **NUNCA** subas a GitHub la clave `secret` ni `service_role`.
- **Supabase gratis pausa el proyecto tras 7 días sin actividad.** Tus datos se conservan; se reactiva con un clic. Entra al menos una vez por semana.
- Límite gratis de Supabase: 500 MB de base de datos y 2 proyectos activos (sobra para este sistema).
- La facturación electrónica real (FEL/SAT) **no** está incluida: sigue siendo comprobante interno.
- El sistema guarda todo como un solo documento por usuario. Funciona muy bien para un negocio con 1 persona (o varias de una en una). Si dos personas editan a la vez, gana el último guardado y el sistema te avisa si detecta conflicto.

---

## PARTE 1 · Crear las cuentas (5 min)

1. Entra a **https://github.com** → *Sign up* → crea tu cuenta (correo, contraseña, usuario). Verifica el correo.
2. Entra a **https://supabase.com** → *Start your project* → regístrate (puedes usar tu cuenta de GitHub).

## PARTE 2 · Configurar Supabase (10 min)

### 2.1 Crear el proyecto
1. En el panel de Supabase: **New project**.
2. **Name:** `punto-blanks`. **Database password:** pulsa *Generate* y **guárdala** en un lugar seguro (no la vas a usar en la web, pero puede servirte luego).
3. **Region:** la más cercana a ti (por ejemplo *East US (North Virginia)* o *South America (São Paulo)*). **Plan:** Free.
4. **Create new project** y espera 1–2 minutos.

### 2.2 Crear las tablas y la seguridad
1. Menú izquierdo → **SQL Editor** → **New query**.
2. Abre el archivo `supabase/schema.sql` de esta carpeta, **copia todo** y pégalo.
3. Pulsa **Run**. Debe decir *Success*. (Si lo ejecutas dos veces no pasa nada.)
4. Comprueba: **Table Editor** → deben aparecer `app_state` y `app_state_history` con el candado de RLS activo.

### 2.2b Crear TU usuario (el único que podrá entrar)
1. Menú izquierdo → **Authentication** → **Users** → **Add user** → **Create new user**.
2. Escribe tu **correo** y una **contraseña fuerte** (mínimo 12 caracteres).
3. Marca **Auto Confirm User** → **Create user**.

### 2.3 Cerrar el registro público (¡importante!)
1. **Authentication** → **Sign In / Providers** (en algunas versiones: *Providers* o *Settings*).
2. Busca **User Signups** / *Allow new users to sign up* y **desactívalo**.
3. Guarda. Así nadie más puede crearse una cuenta en tu proyecto.

### 2.4 Copiar tus 2 datos públicos
1. **Project URL:** botón **Connect** (arriba) o *Settings → Data API*. Tiene la forma `https://abcdefghij.supabase.co`.
2. **Publishable key:** *Settings → API Keys*. Si no ves ninguna, pulsa **Create new API Keys** y copia la que empieza con `sb_publishable_...`.
   - No uses la `secret` ni la `service_role`.
   - (Las claves antiguas `anon` también funcionan por ahora, pero Supabase planea retirarlas a fines de 2026; usa la publishable.)

## PARTE 3 · Subir la web a GitHub (10 min)

### 3.1 Crear el repositorio
1. En GitHub: **+** (arriba a la derecha) → **New repository**.
2. **Repository name:** `punto-blanks`. **Public** (obligatorio para Pages gratis). No marques README.
3. **Create repository**.

### 3.2 Subir los archivos (sin instalar nada)
1. En la página del repo nuevo pulsa **uploading an existing file**.
2. Arrastra **todo el contenido** de la carpeta `punto-blanks`: `index.html`, `config.js`, `GUIA.md`, `README.md`, `.gitignore`, `.nojekyll` y la carpeta `supabase` (con `schema.sql`).
   - Si tu sistema no deja arrastrar archivos ocultos (`.gitignore`, `.nojekyll`), no pasa nada: `index.html` y `config.js` son lo esencial.
3. **Commit changes**.

### 3.3 Poner TUS datos en `config.js`
1. En el repo abre `config.js` → icono del **lápiz** (Edit).
2. Pega tu URL y tu clave publishable entre las comillas:
   ```js
   window.PB_CONFIG = {
     url: "https://TUPROYECTO.supabase.co",
     key: "sb_publishable_XXXXXXXX"
   };
   ```
3. **Commit changes**.

### 3.4 Activar GitHub Pages
1. Repo → **Settings** → **Pages** (menú izquierdo).
2. **Build and deployment** → *Source:* **Deploy from a branch**.
3. *Branch:* **main** y carpeta **/ (root)** → **Save**.
4. Espera 1–3 minutos y recarga. Arriba aparecerá tu dirección: `https://TUUSUARIO.github.io/punto-blanks/`.

### (Alternativa con Git en la terminal)
```bash
cd punto-blanks
git init
git add .
git commit -m "PUNTO BLANKS"
git branch -M main
git remote add origin https://github.com/TUUSUARIO/punto-blanks.git
git push -u origin main
```

## PARTE 4 · Primer uso (5 min)

1. Abre tu dirección de Pages. Verás la pantalla **PUNTO BLANKS · Inicie sesión**.
2. Entra con el correo y contraseña del paso 2.2b.
3. En el encabezado verás **☁ Sincronizado**. Al hacer cambios verás *Guardando…* y luego *Sincronizado*.
4. La primera vez trae **datos de demostración**. Para empezar limpio: pestaña **Impuestos y reportes** → abajo → **Empezar en blanco** (borra todo y lo guarda así en la nube).
5. Comprueba en Supabase: **Table Editor → app_state** debe mostrar **1 fila** con tu `user_id`.

> Si ya usabas el sistema en un navegador (modo local), esos datos se suben a la nube la **primera vez** que inicias sesión **si la nube está vacía**. Si la nube ya tiene datos, la nube manda.

## PARTE 5 · Cómo se sincroniza

- Cada cambio se guarda en el navegador al instante y se sube a Supabase 1,5 s después.
- Al abrir o volver a la pestaña, el sistema revisa si otro dispositivo cambió algo y lo descarga.
- **Sin internet:** sigue funcionando y marca *⚠ Sin conexión: guardado local*. Al volver la conexión, sube los cambios.
- **Conflicto** (cambios distintos en dos dispositivos): te pregunta si usar la nube o conservar este dispositivo.
- **Salir:** sube lo pendiente, cierra sesión y borra la copia local de este equipo (útil en computadoras compartidas).

## PARTE 6 · Lista de seguridad

- [ ] Registro público desactivado (2.3).
- [ ] Contraseña fuerte y única; no la compartas.
- [ ] En el repo solo están la URL y la clave **publishable** (nunca `secret`/`service_role`).
- [ ] RLS activo en ambas tablas (candado en Table Editor).
- [ ] Opcional: en **Authentication → Attack Protection** activa protección contra bots (CAPTCHA).
- [ ] Para dar acceso a otra persona, créale su propio usuario (2.2b); cada usuario tiene sus propios datos separados.

## PARTE 7 · Respaldos y restauración

- El sistema guarda automáticamente una copia (en `app_state_history`) la primera vez que guardas después de 1 hora sin cambios, y conserva 60 días.
- Para ver o restaurar un respaldo, usa las consultas comentadas al final de `supabase/schema.sql` en el **SQL Editor**.
- Recomendado: una vez al mes, en *Table Editor → app_state*, exporta como CSV (botón **Export**) y guárdalo.

## PARTE 8 · Mantenimiento

- **Evitar que se pause:** entra al menos 1 vez por semana. Si se pausó: panel de Supabase → tu proyecto → **Restore project**. Tus datos se conservan.
- **Actualizar la web:** en GitHub edita o reemplaza `index.html` (lápiz o *Add file → Upload files*) → Commit. Pages se republica solo en 1–3 minutos.
- **Cambiar contraseña:** Supabase → Authentication → Users → tu usuario → *Send password recovery* o *Reset password*.
- **Dominio propio (opcional):** Settings → Pages → Custom domain.

## PARTE 9 · Problemas frecuentes

| Síntoma | Causa y solución |
|---|---|
| Pantalla en blanco / 404 | Pages aún no terminó (espera 3 min) o la rama/carpeta no es *main* / *root*. |
| Entra directo sin pedir login y dice *Modo local* | `config.js` está vacío o mal escrito (url/key). Revisa comillas y que esté guardado en GitHub. |
| "Correo o contraseña incorrectos" | Usuario no creado o sin *Auto Confirm User*. Créalo de nuevo en Authentication → Users. |
| "⚠ Sin conexión" aunque hay internet | No corriste `schema.sql`, o la URL/clave es de otro proyecto, o el proyecto está pausado. |
| No se pudo cargar Supabase | Sin internet o bloqueador de contenido. Botón *Trabajar sin conexión* usa datos locales. |
| Borré datos por error | Restaura un respaldo (Parte 7). |
