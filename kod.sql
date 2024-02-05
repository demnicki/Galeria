/* Tworzenie sekwencji do tabel. */
CREATE SEQUENCE sek_pliki
MINVALUE 1
MAXVALUE 999
START WITH 1;

/* Tworzenie tabeli „rodzaje plików”. */
CREATE TABLE rodzaje_plikow(
kod      CHAR(4 CHAR) NOT NULL,
typ_mime VARCHAR2(100 CHAR) NOT NULL,
CONSTRAINT glowny_rodzaje_plikow PRIMARY KEY (kod));


/* Tworzenie tabeli „pliki”. */
CREATE TABLE pliki(
id       NUMBER DEFAULT ON NULL sek_pliki.NEXTVAL NOT NULL,
plik     BLOB,
nazwa    VARCHAR2(300 CHAR) DEFAULT 'nowy_plik' NOT NULL,
kod_typu CHAR(4 CHAR) NOT NULL,
opis     VARCHAR2(1000 CHAR),
CONSTRAINT glowny_pliki PRIMARY KEY (id),
CONSTRAINT obcy_rodzaje_plikow FOREIGN KEY (kod_typu) REFERENCES rodzaje_plikow(kod));

/* Utworzenie kontrolera REST. */

/* Inicjacja. */
BEGIN
  ords.enable_schema(
    p_enabled             => TRUE,
    p_schema              => '?',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'api',
    p_auto_rest_auth      => FALSE
  );    
  COMMIT;
END;

/* Tworzenie modułu */
BEGIN
  ords.define_module(
    p_module_name    => 'pliki',
    p_base_path      => 'pliki/',
    p_items_per_page => 0);
  COMMIT;
END;

/* Utworzenie kontrolera REST. */
BEGIN
  ords.define_template(
    p_module_name    => 'pliki',
    p_pattern        => 'plik/:n');

  ords.define_handler(
    p_module_name    => 'pliki',
    p_pattern        => 'plik/:n',
    p_method         => 'GET',
    p_source_type    => ords.source_type_plsql,
    p_source         => q'[DECLARE
                        z_blob BLOB;
                        n NUMBER(1);
                        BEGIN
                        SELECT count(id) INTO n FROM pliki WHERE id = :n;
                        IF n = 1 THEN
                        SELECT plik INTO z_blob FROM pliki WHERE id = :n;
                        wpg_docload.download_file(z_blob);
                        ELSE
                        htp.p('<h1>Nie ma takiego pliku...</h1>');
                        END IF;
                        END;]',
    p_items_per_page => 0);

  ords.define_parameter(
    p_module_name        => 'pliki',
    p_pattern            => 'plik/:n',
    p_method             => 'GET',
    p_name               => 'n',
    p_bind_variable_name => 'n',
    p_source_type        => 'HEADER',
    p_param_type         => 'STRING',
    p_access_method      => 'IN'
    );
  
  COMMIT;
END;

/* Programowanie poszczególnych podstron. */

/* SELECTy do galerii zdjęć. */

SELECT id, nazwa, plik FROM pliki WHERE
	nazwa LIKE 'p%' AND
	kod_typu = 'jpg' OR
	kod_typu = 'png' OR
	kod_typu = 'gif';

SELECT id, nazwa, plik FROM pliki WHERE
	nazwa LIKE 'k%' AND
	kod_typu = 'jpg' OR
	kod_typu = 'png' OR
	kod_typu = 'gif';

SELECT plik FROM pliki WHERE
	id = :?_ID;

/* Utworzenie procesu AJAX callback. */
DECLARE
    n NUMBER(1);
    z_nazwa pliki.nazwa%TYPE;

BEGIN
    SELECT count(id) INTO n FROM pliki WHERE id = apex_application.g_x01;
    SELECT nazwa INTO z_nazwa FROM pliki WHERE id = apex_application.g_x01;
    IF n = 1 THEN
        DELETE FROM pliki WHERE id = apex_application.g_x01;
        COMMIT;
        apex_json.open_object;
        apex_json.write('nazwa', z_nazwa);
        apex_json.close_object;
    END IF;
END;