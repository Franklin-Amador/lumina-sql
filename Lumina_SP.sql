-- * Procedimiento para solicitudes pendientes ordenadas por fecha
CREATE  OR ALTER PROCEDURE lum.sp_GetSolicitudesPendientesOrdenadas
AS
BEGIN
    SELECT 
        Id_Solicitud,
        Id_Especialidad,
        primer_Nombre,
        segundo_Nombre,
        primer_Apellido,
        segundo_Apellido,
        mail,
        Fecha_Solicitud,
        Estado,
        Descripción,
        ImagenUrl
    FROM 
        lum.Solicitudes
    WHERE 
        Estado = 'Pendiente'
    ORDER BY 
        Fecha_Solicitud ASC;
END;


-- * Procedimiento para procesar las solicitudes
CREATE OR ALTER PROCEDURE lum.ProcesarSolicitud
    @Id_Solicitud INT,
    @Resultado NVARCHAR(MAX) OUTPUT,
    @CorreoInstructor NVARCHAR(100) OUTPUT
AS
BEGIN
    BEGIN TRANSACTION

    -- Variables para manejar errores
    DECLARE @Error INT
    SET @Error = 0

    -- Variables para almacenar datos de la solicitud
    DECLARE @primer_Nombre NVARCHAR(50)
    DECLARE @segundo_Nombre NVARCHAR(50)
    DECLARE @primer_Apellido NVARCHAR(50)
    DECLARE @segundo_Apellido NVARCHAR(50)
    DECLARE @mail NVARCHAR(100)
    DECLARE @Id_Especialidad INT
    DECLARE @Id_Usuario INT
    DECLARE @Id_Instructor INT

    -- Obtener datos de la solicitud especificada
    SELECT @primer_Nombre = primer_Nombre,
           @segundo_Nombre = segundo_Nombre,
           @primer_Apellido = primer_Apellido,
           @segundo_Apellido = segundo_Apellido,
           @mail = mail,
           @Id_Especialidad = Id_Especialidad
    FROM lum.Solicitudes
    WHERE Id_Solicitud = @Id_Solicitud
      AND Estado = 'Pendiente'

    IF @@ROWCOUNT = 0
    BEGIN
        -- Si no se encuentra la solicitud o no está pendiente, abortar la transacción
        ROLLBACK TRANSACTION
        SET @Resultado = 'No se encontró una solicitud pendiente con el Id_Solicitud especificado.'
        SET @CorreoInstructor = NULL
        SELECT @Resultado AS Resultado, @CorreoInstructor AS CorreoInstructor
        RETURN
    END

    BEGIN TRY
        -- Inserción en la tabla Usuarios
        INSERT INTO lum.Usuarios (Id_Rol,Id_Estado, primer_Nombre, segundo_Nombre, primer_Apellido, segundo_Apellido, mail)
        VALUES (3, 1, @primer_Nombre, @segundo_Nombre, @primer_Apellido, @segundo_Apellido, @mail)

        SET @Id_Usuario = SCOPE_IDENTITY()

        -- Inserción en la tabla Instructores
        INSERT INTO lum.Instructores (Id_Usuario, active)
        VALUES (@Id_Usuario, 'active')

        SET @Id_Instructor = SCOPE_IDENTITY()

        -- Inserción en la tabla InstructorEspecialidad
        INSERT INTO lum.InstructorEspecialidad (Id_Especialidad, Id_Instructor)
        VALUES (@Id_Especialidad, @Id_Instructor)

        -- Actualizar el estado de la solicitud a 'Aprobada'
        UPDATE lum.Solicitudes
        SET Estado = 'Aprobada'
        WHERE Id_Solicitud = @Id_Solicitud

        SET @CorreoInstructor = @mail
        SET @Resultado = 'Éxito'

        -- Confirmar la transacción
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        SET @Error = 1
        -- Deshacer la transacción si ocurre un error
        ROLLBACK TRANSACTION
        SET @Resultado = ERROR_MESSAGE()
        SET @CorreoInstructor = NULL
    END CATCH

    SELECT @Resultado AS Resultado, @CorreoInstructor AS CorreoInstructor
END;


-- * Procedimiento para rechazar Solicitud
CREATE PROCEDURE lum.RechazarSolicitud
    @Id_Solicitud INT
AS
BEGIN
    BEGIN TRANSACTION;

    -- Manejo de errores
    BEGIN TRY
        -- Actualizar el campo Estado a 'rechazada'
        UPDATE lum.Solicitudes
        SET Estado = 'Rechazada'
        WHERE Id_Solicitud = @Id_Solicitud;

        -- Confirmar la transacción si la operación es exitosa
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Revertir la transacción en caso de error
        ROLLBACK TRANSACTION;

        -- Lanzar el error
        THROW;
    END CATCH
END;

-- * Procedimiento para obtener información de los instructores
CREATE PROCEDURE lum.ObtenerInformacionInstructores
AS
BEGIN
    -- Obtener información de los instructores
    SELECT
        u.primer_Nombre + ' ' + ISNULL(u.segundo_Nombre, '') + ' ' + u.primer_Apellido + ' ' + ISNULL(u.segundo_Apellido, '') AS Nombre_Completo,
        u.mail AS Correo,
        e.Nombre AS Especialidad,
        COUNT(DISTINCT c.Id_Curso) AS Cantidad_Cursos,
        AVG(ins.Score) AS Promedio_Score,
        COUNT(ins.Id_Inscripcion) AS Cantidad_Inscripciones,
        u.ImagenUrl 
    FROM
        lum.Instructores i
    INNER JOIN
        lum.Usuarios u ON i.Id_Usuario = u.Id_Usuario
    INNER JOIN
        lum.InstructorEspecialidad ie ON i.Id_Instructor = ie.Id_Instructor
    INNER JOIN
        lum.Especialidades e ON ie.Id_Especialidad = e.Id_Especialidad
    LEFT JOIN
        lum.Cursos c ON i.Id_Instructor = c.Id_Instructor
    LEFT JOIN
        lum.Inscripciones ins ON c.Id_Curso = ins.Id_Curso
        
        -- Agrupar por los campos requeridos   
    GROUP BY
        u.primer_Nombre,
        u.segundo_Nombre,
        u.primer_Apellido,
        u.segundo_Apellido,
        u.mail,
        e.Nombre,
        u.ImagenUrl; 
END;