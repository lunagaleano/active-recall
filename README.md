# Active Recall

Plataforma para organizar materias, tareas, exámenes y entregas. Frontend en un solo archivo (`index.html`) + Supabase (Auth y PostgreSQL con RLS).

## Estructura

```
active-recall/
├── index.html      # toda la aplicación (HTML, CSS y JS)
├── supabase.sql    # tablas, trigger de perfil y políticas RLS
└── README.md
```

## 1. Configurar Supabase

1. Creá una cuenta y un proyecto en https://supabase.com (gratis).
2. Andá a **SQL Editor**, pegá todo `supabase.sql` y ejecutalo (**Run**).
3. Andá a **Project Settings > API** y copiá:
   - **Project URL**
   - **anon public key** (la `service_role` NO se usa nunca en el frontend)
4. Abrí `index.html` y reemplazá al principio del script:
   ```js
   const CFG={URL:'TU_SUPABASE_URL',KEY:'TU_SUPABASE_ANON_KEY'};
   ```
5. **Authentication > Providers > Email**: por defecto exige confirmar el correo. Para probar rápido podés desactivar "Confirm email"; en producción conviene dejarlo activo.
6. **Authentication > URL Configuration**: en *Site URL* poné la URL donde publiques la página (o `http://localhost:8000` para pruebas).

La clave anon es pública por diseño: la seguridad real la dan las políticas RLS del SQL, que hacen que cada usuario solo vea y modifique sus propios registros.

## 2. Ejecutar localmente

Necesitás internet (se carga supabase-js desde CDN). Desde la carpeta del proyecto:

```bash
python3 -m http.server 8000
```

Abrí http://localhost:8000. (Evitá abrir el archivo con doble clic: algunos navegadores bloquean la sesión desde `file://`.)

## 3. Publicar en internet

Es un sitio estático, sirve cualquier hosting:

- **Netlify**: https://app.netlify.com/drop y arrastrá la carpeta.
- **Vercel**: `npx vercel` dentro de la carpeta.
- **GitHub Pages**: subí los archivos a un repo y activá Pages en *Settings > Pages*.

Después de publicar, actualizá *Site URL* en Supabase con la URL final.

## Qué incluye

Registro (con validación de contraseñas y correo duplicado), inicio y cierre de sesión con sesión persistente, dashboard con resumen, progreso y actividad reciente, materias (crear, editar, eliminar, vista propia por materia), tareas (CRUD, prioridad, estado, filtros y orden), exámenes y entregas, calendario diario/semanal/mensual, recordatorios (1 día, 2 días o 1 semana antes), perfil, cambio de contraseña y diseño responsive.

## Limitaciones

- Los recordatorios se muestran dentro de la plataforma cuando la abrís. Las notificaciones del navegador (que piden permiso) solo funcionan con la página abierta; no hay servicio que avise con el navegador cerrado.
- Sección "tiempos de estudio" del texto inicial: no está incluida, porque no figura en los requerimientos funcionales.
