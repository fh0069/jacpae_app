# Configuración del Entorno de Desarrollo

## Variables de Entorno para Supabase

Para evitar tener que escribir las credenciales de Supabase en cada ejecución, tienes varias opciones:

---

## Opción 1: Archivo `.env` (Recomendado para desarrollo)

### Paso 1: Crear archivo .env

```bash
# Copiar el archivo de ejemplo
cp .env.example .env
```

### Paso 2: Editar .env con tus credenciales

Abre `.env` y reemplaza con tus valores reales:

```bash
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Paso 3: Ejecutar con scripts helper

#### Windows:
```bash
run_dev.bat
```

#### macOS/Linux:
```bash
./run_dev.sh
```

Los scripts automáticamente cargan las variables desde `.env` y ejecutan la app.

⚠️ **Importante**: El archivo `.env` está en `.gitignore` y NUNCA se subirá a GitHub.

---

## Opción 2: VS Code Launch Configuration

Si usas VS Code, ya está configurado un perfil de ejecución.

### Paso 1: Editar .vscode/launch.json

Abre [.vscode/launch.json](../.vscode/launch.json) y reemplaza:

```json
"args": [
  "--dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co",
  "--dart-define=SUPABASE_ANON_KEY=TU-ANON-KEY-AQUI"
]
```

### Paso 2: Ejecutar desde VS Code

1. Presiona `F5` o ve a Run → Start Debugging
2. Selecciona "Flutter (Dev - Supabase)" en el dropdown
3. La app se ejecutará con tus credenciales

⚠️ **Importante**:
- El archivo `.vscode/launch.json` está compartido en el repo por defecto
- Si trabajas en equipo, **NO subas tus credenciales** al repo
- Considera añadir `.vscode/` al `.gitignore` si prefieres mantener tu configuración privada

---

## Opción 3: Variables de entorno del sistema (macOS/Linux)

### Bash/Zsh (.bashrc, .zshrc)

Añade al final de `~/.bashrc` o `~/.zshrc`:

```bash
export SUPABASE_URL="https://tu-proyecto.supabase.co"
export SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

Luego ejecuta:
```bash
source ~/.bashrc  # o ~/.zshrc
```

### Ejecutar la app

```bash
flutter run \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

---

## Opción 4: Variables de entorno del sistema (Windows)

### Variables de entorno permanentes

1. Búsqueda de Windows → "Variables de entorno"
2. Click en "Variables de entorno"
3. En "Variables de usuario", click "Nueva"
4. Añadir:
   - Nombre: `SUPABASE_URL`
   - Valor: `https://tu-proyecto.supabase.co`
5. Repetir para `SUPABASE_ANON_KEY`
6. Reiniciar terminal/IDE

### Ejecutar la app

```bash
flutter run --dart-define=SUPABASE_URL=%SUPABASE_URL% --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY%
```

O usar `run_dev.bat` que carga desde `.env`

---

## Opción 5: Script personalizado

### PowerShell (Windows)

Crear `run.ps1`:

```powershell
$env:SUPABASE_URL = "https://tu-proyecto.supabase.co"
$env:SUPABASE_ANON_KEY = "tu-anon-key"

flutter run `
  --dart-define=SUPABASE_URL=$env:SUPABASE_URL `
  --dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY
```

Ejecutar:
```powershell
.\run.ps1
```

---

## Obtener tus credenciales de Supabase

1. Ve a [Supabase Dashboard](https://supabase.com/dashboard)
2. Selecciona tu proyecto
3. Ve a **Settings** → **API**
4. Copia:
   - **Project URL**: Este es tu `SUPABASE_URL`
   - **anon/public key**: Este es tu `SUPABASE_ANON_KEY`

⚠️ **NUNCA uses la service_role key en el cliente Flutter**

---

## Verificar configuración

Para verificar que las variables están correctamente configuradas:

### Windows (CMD):
```bash
echo %SUPABASE_URL%
echo %SUPABASE_ANON_KEY%
```

### Windows (PowerShell):
```powershell
echo $env:SUPABASE_URL
echo $env:SUPABASE_ANON_KEY
```

### macOS/Linux:
```bash
echo $SUPABASE_URL
echo $SUPABASE_ANON_KEY
```

---

## Seguridad

✅ **Hacer:**
- Usar `.env` para desarrollo local
- Añadir `.env` al `.gitignore`
- Usar solo la `anon key` en el cliente
- Usar variables de entorno en CI/CD

❌ **NO hacer:**
- Hardcodear credenciales en el código
- Subir `.env` a GitHub
- Compartir `service_role key` públicamente
- Exponer credenciales en logs

---

## Troubleshooting

### Error: "Supabase credentials not found!"

**Causa**: Las variables no están definidas o están vacías.

**Solución**:
1. Verifica que `.env` existe y tiene las credenciales
2. Si usas scripts, verifica que se ejecutan correctamente
3. Si usas VS Code, verifica `launch.json`
4. Reinicia tu terminal/IDE

### Error: Script no reconocido (Windows)

**Causa**: PowerShell puede bloquear scripts por política de ejecución.

**Solución**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: Permission denied (macOS/Linux)

**Causa**: Script no tiene permisos de ejecución.

**Solución**:
```bash
chmod +x run_dev.sh
```

---

## Resumen

**Recomendación por plataforma:**

| Plataforma | Método Recomendado |
|------------|-------------------|
| Windows + VS Code | `.vscode/launch.json` o `run_dev.bat` |
| Windows + Terminal | `run_dev.bat` con `.env` |
| macOS/Linux + VS Code | `.vscode/launch.json` |
| macOS/Linux + Terminal | `./run_dev.sh` con `.env` |
| CI/CD | Variables de entorno del sistema |

**Para desarrollo rápido**: Usa `.env` + scripts helper (`run_dev.bat` o `run_dev.sh`)

**Para VS Code**: Edita `.vscode/launch.json` y presiona F5
