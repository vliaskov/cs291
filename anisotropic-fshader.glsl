uniform vec3 uMaterialColor;
uniform vec3 uSpecularColor;

uniform vec3 uDirLightPos;
uniform vec3 uDirLightColor;

uniform vec3 uAmbientLightColor;

uniform float uKd;
uniform float uKs;
uniform float shininess;

uniform float uGroove;

varying vec3 vNormal;
varying vec3 vViewPosition;
varying vec3 vWorldPosition;

void main() {

	// ambient
	gl_FragColor = vec4( uAmbientLightColor, 1.0 );

	// compute direction to light
	vec4 lDirection = viewMatrix * vec4( uDirLightPos, 0.0 );
	vec3 lVector = normalize( lDirection.xyz );

	vec3 normal = normalize( vNormal );
	
	// Student: use these two jiggledNormals instead of the regular normal
	// in the reflection model that follows.
    // specular: N * H to a power. H is light vector + view vector
	vec3 viewPosition = normalize( vViewPosition );
	vec3 pointHalfVector = normalize( lVector + viewPosition );
    float specular = 0.0;
        
	for ( int i = 0; i < 2; i++) {
		vec3 offset = (i==0) ? vWorldPosition : -vWorldPosition;
		offset.y = 0.0;
		vec3 jiggledNormal = normalize( normal + uGroove * normalize( offset ) );
        float diffuse = max( dot( jiggledNormal, lVector ), 0.0);
        gl_FragColor.rgb += 0.5 * uKd * uMaterialColor * uDirLightColor * diffuse;
        float pointDotNormalHalf = max( dot( jiggledNormal, pointHalfVector ), 0.0 );
        specular = uKs * pow( pointDotNormalHalf, shininess );
        specular *= diffuse*(2.0 + shininess)/8.0;

        // This can give a hard termination to the highlight, but it's better than some weird sparkle.
        // Note: we don't quit here because the solution will use this code twice.
        if (diffuse <= 0.0) {
            specular = 0.0;
        }

        gl_FragColor.rgb += 0.5 * uDirLightColor * uSpecularColor * specular;
	}
	
	// diffuse: N * L. Normal must be normalized, since it's interpolated.
	
}
