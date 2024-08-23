CREATE SCHEMA lum;

-- * Tabla: Instituciones
CREATE TABLE lum.Instituciones (
    Id_Institucion INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    direccion NVARCHAR(255),
    email NVARCHAR(100)
);

-- * Tabla: Plan
CREATE TABLE lum.Planes (
    Id_Plan INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    duracion INT,
    costo DECIMAL(10, 2)
);

-- * Tabla: CaracteristicasPlan
CREATE TABLE lum.CaracteristicasPlan (
    Id_Caracteristica INT IDENTITY(1,1) PRIMARY KEY,
    Id_Plan INT,
    descripcion NVARCHAR(MAX),
    CONSTRAINT FK_CaracteristicasPlan_Plan FOREIGN KEY (Id_Plan) REFERENCES lum.Planes(Id_Plan)
);

-- * Tabla: Subscripciones
CREATE TABLE lum.Subscripciones (
    Id_Subscripcion INT IDENTITY(1,1) PRIMARY KEY,
    Id_Institucion INT,
    Id_Plan INT,
    Fecha_Inicio DATE,
    Fecha_Final DATE,
    CONSTRAINT FK_Subscripciones_Instituciones FOREIGN KEY (Id_Institucion) REFERENCES lum.Instituciones(Id_Institucion),
    CONSTRAINT FK_Subscripciones_Plan FOREIGN KEY (Id_Plan) REFERENCES lum.Planes(Id_Plan)
);

-- * Tabla: Roles
CREATE TABLE lum.Roles (
    Id_Rol INT IDENTITY(1,1) PRIMARY KEY,
    rol NVARCHAR(50) NOT NULL
);

-- * Tabla: Estado
CREATE TABLE lum.Estado (
    Id_Estado INT IDENTITY(1,1) PRIMARY KEY,
    Estado NVARCHAR(50) NOT NULL
);

-- * Tabla: Usuarios
CREATE TABLE lum.Usuarios (
    Id_Usuario INT IDENTITY(1,1) PRIMARY KEY,
    Id_Rol INT,
    Id_Estado INT DEFAULT 1,
    primer_Nombre NVARCHAR(50) NOT NULL,
    segundo_Nombre NVARCHAR(50),
    primer_Apellido NVARCHAR(50) NOT NULL,
    segundo_Apellido NVARCHAR(50),
    mail NVARCHAR(50) NOT NULL UNIQUE,
    Puntos INT DEFAULT 0,
    ImagenUrl NVARCHAR(255)
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (Id_Rol) REFERENCES lum.Roles(Id_Rol),
    CONSTRAINT FK_Usuarios_Estado FOREIGN KEY (Id_Estado) REFERENCES lum.Estado(Id_Estado)
);

-- * Tabla: Instructores
CREATE TABLE lum.Instructores (
    Id_Instructor INT IDENTITY(1,1) PRIMARY KEY,
    Id_Usuario INT,
    active NVARCHAR(12),
    CONSTRAINT FK_Instructores_Usuarios FOREIGN KEY (Id_Usuario) REFERENCES lum.Usuarios(Id_Usuario)
);

-- * Tabla: Categorias
CREATE TABLE lum.Categorias (
    Id_Categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL
);

-- * Tabla: Especialidades
CREATE TABLE lum.Especialidades (
    Id_Especialidad INT IDENTITY(1,1) PRIMARY KEY,
    Id_Categoria INT,
    Nombre NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Especialidades_Categorias FOREIGN KEY (Id_Categoria)
    REFERENCES lum.Categorias(Id_Categoria)
);

-- * Tabla: InstructorEspecialidad
CREATE TABLE lum.InstructorEspecialidad (
    Id_Inst_Esp INT IDENTITY(1,1) PRIMARY KEY,
    Id_Especialidad INT,
    Id_Instructor INT,
    CONSTRAINT FK_InstructorEspecialidad_Especialidades FOREIGN KEY (Id_Especialidad) REFERENCES lum.Especialidades(Id_Especialidad),
    CONSTRAINT FK_InstructorEspecialidad_Instructores FOREIGN KEY (Id_Instructor) REFERENCES lum.Instructores(Id_Instructor)
);

-- * Tabla: Admins
CREATE TABLE lum.Admins (
    Id_Administrador INT IDENTITY(1,1) PRIMARY KEY,
    Id_Usuario INT,
    CONSTRAINT FK_Admins_Usuarios FOREIGN KEY (Id_Usuario) REFERENCES lum.Usuarios(Id_Usuario)
);

-- * Tabla: Cursos
CREATE TABLE lum.Cursos (
    Id_Curso INT IDENTITY(1,1) PRIMARY KEY,
    Id_Categoria INT,
    Id_Instructor INT,
    Precio MONEY,
    Precio_puntos INT,
    Nombre NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Cursos_Categorias FOREIGN KEY (Id_Categoria) REFERENCES lum.Categorias(Id_Categoria),
    CONSTRAINT FK_Cursos_Instructores FOREIGN KEY (Id_Instructor) REFERENCES lum.Instructores(Id_Instructor)
);

-- * Tabla: Modulos
CREATE TABLE lum.Modulos (
    Id_Modulo INT IDENTITY(1,1) PRIMARY KEY,
    Id_Curso INT,
    titulo NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(MAX),
    CONSTRAINT FK_Modulos_Cursos FOREIGN KEY (Id_Curso) REFERENCES lum.Cursos(Id_Curso)
);

-- * Tabla: Videos
CREATE TABLE lum.Videos (
    Id_Video INT IDENTITY(1,1) PRIMARY KEY,
    Id_Modulo INT,
    URL NVARCHAR(MAX) NOT NULL,
    Titulo NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Videos_Modulos FOREIGN KEY (Id_Modulo) REFERENCES lum.Modulos(Id_Modulo)
);

-- * Tabla: Inscripciones
CREATE TABLE lum.Inscripciones (
    Id_Inscripcion INT IDENTITY(1,1) PRIMARY KEY,
    Id_Usuario INT,
    Id_Curso INT,
    fecha_Inscripcion DATE,
    Score INT,
    Progreso INT DEFAULT 0,
    CONSTRAINT FK_Inscripciones_Usuarios FOREIGN KEY (Id_Usuario) REFERENCES lum.Usuarios(Id_Usuario),
    CONSTRAINT FK_Inscripciones_Cursos FOREIGN KEY (Id_Curso) REFERENCES lum.Cursos(Id_Curso),
    CONSTRAINT DF_Inscripciones_fecha_Inscripcion DEFAULT CONVERT(DATE, GETDATE()) FOR fecha_Inscripcion
);

-- * Tabla: Comentarios
CREATE TABLE lum.Comentarios (
    Id_Comentario INT IDENTITY(1,1) PRIMARY KEY,
    Id_Usuario INT,
    Id_Curso INT,
    contenido NVARCHAR(MAX) NOT NULL,
    Fecha DATE NOT NULL,
    CONSTRAINT FK_Comentarios_Usuarios FOREIGN KEY (Id_Usuario) REFERENCES lum.Usuarios(Id_Usuario),
    CONSTRAINT FK_Comentarios_Cursos FOREIGN KEY (Id_Curso) REFERENCES lum.Cursos(Id_Curso)
);

-- * Tabla: Solicitudes
CREATE TABLE lum.Solicitudes (
    Id_Solicitud INT IDENTITY(1,1) PRIMARY KEY,
    Id_Especialidad INT NOT NULL,
    primer_Nombre NVARCHAR(50) NOT NULL,
    segundo_Nombre NVARCHAR(50),
    primer_Apellido NVARCHAR(50) NOT NULL,
    segundo_Apellido NVARCHAR(50),
    mail NVARCHAR(100) NOT NULL,
    Fecha_Solicitud DATETIME DEFAULT GETDATE(),
    Estado NVARCHAR(50) DEFAULT 'Pendiente',
    Descripción NVARCHAR(MAX),
    ImagenUrl NVARCHAR(255),
    CONSTRAINT FK_Solicitudes_Especialidades FOREIGN KEY (Id_Especialidad) REFERENCES lum.Especialidades(Id_Especialidad)
);