#include "ReShade.fxh"

uniform int Type <
        ui_type = "combo";
        ui_items = "Defring\0";
> = 0;

texture red_tex < source = "red.png"; > {Width = 1280; Height = 800; Format = RGBA8;};
texture green_tex < source = "green.png"; > {Width = 1280; Height = 800; Format = RGBA8;};

sampler red_s { Texture = red_tex; };
sampler green_s { Texture = green_tex; };


float3 MuraCorr(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
    float3 input = tex2D(ReShade::BackBuffer, texcoord).rgb;

    // Check if the input color is approximately black
    if (length(input.rgb) < 0.001) // You can adjust this threshold as needed
    {
        // Return black color without any correction
        return input.rgb;
    }

    float3 red = tex2D(red_s, texcoord.xy).rgb;
    float3 green = tex2D(green_s, texcoord.xy).rgb;

    // Apply correction only if the input color is not black
    float kMuraMapScale = 0.0625;

    float3 correction;
    correction.r = input.r + ((red.r - 0.5) * kMuraMapScale);
    correction.b = input.b; // + ( 0.5 * kMuraMapScale );
    correction.g = input.g + ((green.g - 0.5) * kMuraMapScale);

    return correction;
}

technique Mura
{
        pass
        {
                VertexShader = PostProcessVS;
                PixelShader = MuraCorr;
        }
}
